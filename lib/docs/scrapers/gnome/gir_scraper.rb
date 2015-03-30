module Docs
  # GirScraper: Instead of being given a path to HTML documentation, this gets a
  # path to a GIR file, which it runs through g-ir-doc-tool and yelp-build to
  # generate the HTML documentation. It also runs a preprocessor on the HTML to
  # fix some of the GtkDoc markup.
  class GirScraper < FileScraper
    require 'docs/filters/mallard/fix_gtkdoc'
    attr_accessor :preprocessor

    class << self
      attr_accessor :c_prefix
      attr_accessor :api_version
      attr_accessor :gir_path
    end

    self.type = 'mallard'
    self.abstract = true
    self.root_path = 'index.html'

    html_filters.push 'mallard/entries', 'mallard/clean_html'

    options[:container] = '.body'

    def initialize
      super
      @preprocessor = FixGtkdocFilter.new
      self.class.dir = run_doctool self.class.gir_path
    end

    def doctool
      ENV['G_IR_DOC_TOOL'].nil? ? 'g-ir-doc-tool' : ENV['G_IR_DOC_TOOL']
    end

    def yelp
      ENV['YELP_BUILD'].nil? ? 'yelp-build' : ENV['YELP_BUILD']
    end

    def run_doctool(gir_path)
      puts 'Generating Mallard documentation...'
      Dir.mktmpdir do |dir|
        unless system "#{doctool} #{gir_path} -o #{dir} -l gjs"
          fail 'g-ir-doc-tool failed'
        end
        run_yelp dir
      end
    end

    def run_yelp(mallard_path)
      puts 'Generating HTML documentation...'
      dir = Dir.mktmpdir
      unless system "#{yelp} html -o #{dir} #{mallard_path}"
        FileUtils.remove_entry dir
        fail 'yelp-build failed'
      end
      dir
    end

    def read_file(path)
      html = super path
      return nil if html.nil?
      preprocessor.process html
    end
  end
end
