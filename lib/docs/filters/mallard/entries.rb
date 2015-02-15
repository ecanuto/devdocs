module Docs
  class Mallard
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
        result
      end

      # "type" is the heading that the documentation page is displayed under, in
      # the left sidebar.
      def get_type
        namespace, object, method = *slug.split('.')
        object, property = *object.split('-', 2)
        return FUNCTIONS_HEADING if object.match(/^[a-z]/)
        return FUNCTION_TYPES_HEADING if object.match(/Func$/)
        return CONSTANTS_HEADING unless object.match(/[a-z]/)
        object
      end
    end
  end
end
