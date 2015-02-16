module Docs
  class Mallard
    # CleanHtmlFilter for Mallard documentation. This gets the HTML into a state
    # where it looks nice in the DevDocs browser.
    class CleanHtmlFilter < Filter
      def call
        # Replace <span class="code"> elements with the more semantic <code>
        css('p span.code').each do |node|
          node.name = 'code'
        end
        doc
      end
    end
  end
end
