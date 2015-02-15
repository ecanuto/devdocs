module Docs
  class Mallard
    # EntriesFilter for Mallard documentation. This figures out the metadata for
    # each page.
    class EntriesFilter < Docs::EntriesFilter
      # "name" is the title that the documentation page has in the left sidebar.
      def get_name
        node = at_css('h1.title')
        result = node.content.strip
        result
      end

      # "type" is the heading that the documentation page is displayed under, in
      # the left sidebar.
      def get_type
        name
      end
    end
  end
end
