module Docs
  class GirScraper
    # EntriesFilter for Mallard documentation. This figures out the metadata for
    # each page.
    class EntriesFilter < Docs::EntriesFilter
      FUNCTIONS_HEADING = '(Functions)'
      FUNCTION_TYPES_HEADING = '(Function Types)'
      CONSTANTS_HEADING = '(Constants)'

      # "name" is the title that the documentation page has in the left sidebar.
      def get_name
        node = at_css('h1')
        node.content.strip
      end

      # "type" is the heading that the documentation page is displayed under, in
      # the left sidebar.
      def get_type
        node = at_css('h1')
        node.content.strip
      end

      def additional_entries
        entries = []

        # Catch enum constants explained on an enum's page
        css('dl.terms dt.terms').each do |node|
          obj, member = *node.content.split('.', 2)
          entries.push [member, nil, obj] if obj == name
        end

        entries
      end
    end
  end
end
