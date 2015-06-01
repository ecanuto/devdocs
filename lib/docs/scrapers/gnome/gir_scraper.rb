module Docs
  # GirScraper: Instead of being given a path to HTML documentation, this gets a
  # path to a GIR file, which it runs through g-ir-doc-tool and yelp-build to
  # generate the HTML documentation.
  class GirScraper < FileScraper
    class << self
      attr_accessor :c_prefix
      attr_accessor :api_version
      attr_accessor :gir_path
    end

    self.type = 'mallard'
    self.abstract = true
    self.root_path = 'index.html'

    html_filters.push 'gir_scraper/entries'

    def initialize
      super
      generator = GirDocGenerator.new
      self.class.dir = generator.generate self.class.gir_path
      puts self.class.dir + '/index.html'
      # FIXME need a way to delete self.class.dir after the operation is done
    end
  end
end
