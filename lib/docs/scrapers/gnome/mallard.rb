module Docs
  class Mallard < FileScraper
    require 'docs/filters/mallard/fix_gtkdoc'
    attr_accessor :preprocessor

    self.type = 'mallard'
    self.abstract = true
    self.root_path = 'index.html'

    html_filters.push 'mallard/entries', 'mallard/clean_html'

    options[:container] = '.body'

    def initialize
      super
      @preprocessor = FixGtkdocFilter.new
    end

    def read_file(path)
      html = super path
      return nil if html.nil?
      preprocessor.process html
    end
  end
end
