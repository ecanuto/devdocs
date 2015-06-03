module Docs
  class GirScraper
    # Filter that fixes all internal GtkDoc links such as function(), #type,
    # etc.
    class FixGtkdocFilter
      NAMESPACES = {
        'atk' => 'Atk',
        'g' => 'GObject',
        'gtk' => 'Gtk'
      }
      KEYWORDS = {
        'FALSE' => 'false',
        'NULL' => 'null',
        'TRUE' => 'true'
      }

      def process(text)
        fix_gtkdoc_markup text, /([A-Za-z_]+)\(\)/, :fix_gtkdoc_link
        fix_gtkdoc_markup text, /[%#]([A-Za-z_]+)(?!:)/, :fix_gtkdoc_link
        fix_gtkdoc_markup text, /@([A-Za-z_]+)/, :fix_atsign_markup
        text
      end

      def fix_gtkdoc_markup(text, regex, replacement)
        text.gsub!(regex) { method(replacement).call($1) }
      end

      # Fixes GtkDoc crosslinks such as function() and %CONSTANT.
      def fix_gtkdoc_link(symbol)
        return "`#{KEYWORDS[symbol]}`" if KEYWORDS.key? symbol
        c_prefix, symbol_link = parse_c_symbol symbol
        key = c_prefix.downcase
        return "`#{symbol}`" unless NAMESPACES.key? key
        namespace = NAMESPACES.fetch key
        link = "#{namespace}.#{symbol_link}"
        "[`#{link}`](#{symbol_link.downcase})"
      end

      def fix_atsign_markup(symbol)
        "`#{symbol}`"
      end

      # Returns the namespace and the rest of the symbol.
      def parse_c_symbol(symbol)
        return symbol.split('_', 2) if symbol.index '_'
        camelcase_match = symbol.match(/^[A-Z][a-z]*/)
        return ['', symbol] unless camelcase_match
        c_prefix = camelcase_match[0]
        [c_prefix, symbol[c_prefix.length..-1]]
      end
    end
  end
end
