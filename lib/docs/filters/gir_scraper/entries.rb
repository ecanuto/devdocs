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
        node = at_css('h1.title')
        result = node.content.strip

        namespace = analyze_mallard_name[0]
        result.sub!(namespace + '.', '')
        result.sub!(type + '.', '')
        result << '()' if type == FUNCTIONS_HEADING || result.match(/prototype\./)
        result.sub!(/prototype\./, '')
        result
      end

      # "type" is the heading that the documentation page is displayed under, in
      # the left sidebar.
      def get_type
        object = analyze_mallard_name[1]
        return FUNCTIONS_HEADING if object.match(/^[a-z]/)
        return FUNCTION_TYPES_HEADING if object.match(/Func$/)
        return CONSTANTS_HEADING unless object.match(/[a-z]/)
        object
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

      def analyze_mallard_name
        namespace, object, method = *slug.split('.')
        object, property = *object.split('-', 2)
        [namespace, object, method, property]
      end
    end
  end
end
