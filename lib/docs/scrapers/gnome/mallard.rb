module Docs
  class Mallard < FileScraper
    self.type = 'mallard'
    self.abstract = true
    self.root_path = 'index.html'

    html_filters.push 'mallard/entries', 'mallard/clean_html',
                      'mallard/fix_gtkdoc'

    options[:container] = '.body'
  end
end
