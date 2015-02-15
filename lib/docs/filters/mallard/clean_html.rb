module Docs
  class Mallard
    # CleanHtmlFilter for Mallard documentation. This gets the HTML into a state
    # where it looks nice in the DevDocs browser.
    class CleanHtmlFilter < Filter
      def call
        doc
      end
    end
  end
end
