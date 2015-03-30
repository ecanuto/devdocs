require 'rexml/document'

# Command-line tools for creating scrapers from GIR files
class GirCLI < Thor
  def self.to_s
    'Gir'
  end

  def initialize(*args)
    require 'docs'
    super
  end

  desc 'generate', 'Generate a scraper from a GIR file'
  def generate(gir_path)
    gir = read_gir gir_path

    namespace = gir.root.elements['namespace']
    scraper_info = process_namespace namespace
    scraper_info[:slug] = generate_slug scraper_info[:name]
    scraper_info[:version] = scraper_info[:apiversion]
    write_scraper gir_path, scraper_info
  end

  no_commands do
    def read_gir(path)
      gir_file = File.new path
      gir = REXML::Document.new gir_file
      gir_file.close
      gir
    end

    def process_namespace(namespace)
      {
        name: namespace.attributes['name'],
        api_version: namespace.attributes['version'],
        c_prefix: namespace.attributes['c:symbol-prefixes']
      }
    end

    def generate_slug(name)
      name.downcase.strip.gsub(/[^\w-]/, '')
    end

    def scraper_code(gir_path, info)
      code = <<-END.strip_heredoc
        module Docs
          class #{info[:slug].capitalize} < Mallard
            # TODO: edit the 'version' element to your liking.
      #{info.each { |k, v| "    self.#{k} = '#{v}'" }.join "\n"}
            self.gir_path = '#{gir_path}'
          end
        end
      END
      code
    end

    def write_scraper(gir_path, info)
      scraper_name = File.join 'lib', 'docs', 'scrapers', 'gnome', 'generated',
                               info[:slug] + '.rb'
      out_file = File.new scraper_name, 'w'
      out_file.write scraper_code(gir_path, info)
    end
  end
end
