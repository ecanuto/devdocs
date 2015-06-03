require 'haml'
require 'nokogiri'
require 'progress_bar'
require 'docs/filters/gir_scraper/fix_gtkdoc'

module Docs
  # Generates templated HTML pages given a GIR file.
  class GirDocGenerator
    attr_accessor :namespace, :pages, :filter, :index

    class <<self
      def abstract
        true
      end
    end

    def initialize
      super
      @filter = Docs::GirScraper::FixGtkdocFilter.new
      @index = []
      @tmpdir = Dir.mktmpdir
    end

    def load_gir(gir_path)
      gir = Nokogiri::XML(File.new gir_path)
      namespace_el = gir.root.at(:namespace)
      @namespace = namespace_el[:name]
      @pages = namespace_el.elements
    end

    def write_index
      index = File.new File.join(@tmpdir, 'index.html'), 'w'
      index.write "<html><body>\n"
      @index.each do |entry|
        index.write "  <a href='#{entry}.html'>#{@namespace}.#{entry}</a>\n"
      end
      index.write "</body></html>\n"
      index.close
    end

    def load_template(name)
      File.read "lib/docs/scrapers/gnome/templates/#{name}.haml"
    rescue
      if name == 'record'
        # In GJS, a record is also a class
        File.read 'lib/docs/scrapers/gnome/templates/class.haml'
      else
        raise 'Element type not known! ' + name
      end
    end

    def get_doc_markdown(elem)
      doc = elem.at(:doc)
      return '' if doc.nil?
      @filter.process(doc.text)
    end

    def render_page(elem)
      return '' unless elem[:'glib:is-gtype-struct-for'].nil?
      template = load_template elem.name
      engine = Haml::Engine.new template
      engine.render self, elem: elem, documentation: get_doc_markdown(elem),
                          typename: elem[:name]
    end

    def write_page(elem)
      name = elem[:name]
      file = File.new File.join(@tmpdir, "#{name}.html"), 'w'
      html = render_page elem
      file.write html
      file.close
      @index << name
    end

    def generate(gir_path)
      load_gir gir_path

      @progress_bar = ::ProgressBar.new @pages.size
      @progress_bar.write

      @pages.map do |elem|
        write_page elem
        @progress_bar.increment!
      end

      write_index
      @tmpdir
    end

    def gtype_to_js_type(typename)
      case typename
      when 'gboolean' then 'Boolean'
      when 'gint' then 'Number'
      when 'utf8' then 'String'
      else typename
      end
    end

    def to_js_type(elem)
      array = elem.at(:array)
      if array
        "Array(#{gtype_to_js_type(array.at(:type)[:name])})"
      else
        gtype_to_js_type(elem.at(:type)[:name])
      end
    end

    def analyze_parameter(elem)
      { name: elem[:name],
        type: to_js_type(elem),
        documentation: get_doc_markdown(elem)
      }
    end

    def analyze_method(elem)
      params = elem.css 'parameters > parameter'
      retval = elem.at(:'return-value')
      { name: elem[:name],
        params: params.map(&method(:analyze_parameter)),
        documentation: get_doc_markdown(elem),
        ret_type: to_js_type(retval),
        ret_documentation: get_doc_markdown(retval)
      }
    end

    # Currently the same as analyze_method(), but we might want to do something
    # with "invoker", for example.
    def analyze_vfunc(elem)
      analyze_method elem
    end

    # Methods called from HAML code

    def render_method(method, name, style_class)
      params = method[:params]
      engine = Haml::Engine.new load_template('method')
      engine.render self, cls: style_class, m: method, name: name,
                          params: params,
                          invocation: (params.map { |p| p[:name] }).join(', ')
    end

    def render_methods(elem)
      methods = elem.css 'method'
      return '' if methods.empty?
      engine = Haml::Engine.new load_template('methods')
      engine.render self, methods: methods.map(&method(:analyze_method))
    end

    def render_vfuncs(elem)
      vfuncs = elem.css 'virtual-method'
      return '' if vfuncs.empty?
      engine = Haml::Engine.new load_template('vfuncs')
      engine.render self, vfuncs: vfuncs.map(&method(:analyze_vfunc))
    end
  end
end
