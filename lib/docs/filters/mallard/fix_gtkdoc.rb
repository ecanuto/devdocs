module Docs
  class Mallard
    # Filter that fixes all internal GtkDoc links such as function(), #type,
    # etc.
    class FixGtkdocFilter < Filter
      NAMESPACES = {
        'g' => 'gobject',
        'gtk' => 'gtk'
      }

      def call
        css('p').each do |node|
          fix_gtkdoc_markup node, /([A-Za-z_]+)\(\)/, :fix_parentheses_link
          fix_gtkdoc_markup node, /@([A-Za-z_]+)/, :fix_atsign_markup
          fix_gtkdoc_markup node, /^(- .*)/, :fix_markdown_list
        end
        doc
      end

      def fix_gtkdoc_markup(node, regex, replacement)
        node.inner_html = node.inner_html.gsub(regex) do
          method(replacement).call($1) rescue $&
        end
      end

      def fix_parentheses_link(symbol)
        c_prefix, symbol_link = parse_c_symbol symbol
        fail "Don't modify the original" unless NAMESPACES.key? c_prefix
        "<a href='#{NAMESPACES.fetch c_prefix}.#{symbol_link}'>#{symbol}</a>"
      end

      def fix_atsign_markup(symbol)
        "<code>#{symbol}</code>"
      end

      def fix_markdown_list(text)
        list = text.split('- ').reject(&:empty?).join '</li><li>'
        "<ul><li>#{list}</li></ul>"
      end

      # Returns the namespace and the rest of the symbol.
      def parse_c_symbol(symbol)
        return symbol.split('_', 2).map(&:downcase) if symbol.index '_'
        camelcase_match = symbol.match(/^[A-Z][a-z]*/)
        return ['', symbol.downcase] unless camelcase_match
        c_prefix = camelcase_match[0]
        [c_prefix, symbol[c_prefix.length..-1]].map(&:downcase)
      end
    end
  end
end
