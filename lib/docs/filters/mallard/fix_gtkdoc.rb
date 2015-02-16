module Docs
  class Mallard
    # Filter that fixes all internal GtkDoc links such as function(), #type,
    # etc.
    class FixGtkdocFilter
      NAMESPACES = {
        'g' => 'gobject',
        'gtk' => 'gtk'
      }

      def process(html)
        fix_gtkdoc_markup html, /([A-Za-z_]+)\(\)/, :fix_gtkdoc_link
        fix_gtkdoc_markup html, /%([A-Za-z_]+)/, :fix_gtkdoc_link
        fix_gtkdoc_markup html, /@([A-Za-z_]+)/, :fix_atsign_markup
        fix_gtkdoc_markup html, /(?<=>)(- (?:.|\n)*?)(?=<\/p>)/,
                          :fix_markdown_list
        fix_gtkdoc_markup html, /\|\[((?:.|\n)*?)\]\|/,
                          :fix_program_listing_markup
        html
      end

      def fix_gtkdoc_markup(html, regex, replacement)
        html.gsub!(regex) { method(replacement).call($1) rescue $& }
      end

      # Fixes GtkDoc crosslinks such as function() and %CONSTANT.
      def fix_gtkdoc_link(symbol)
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

      def fix_program_listing_markup(text)
        language = ''
        if text.sub!(/^&lt;!-- language="(.*)" --&gt;\n/, '')
          language = " language='#{$1}'"
        end

        # <p> tags get added by Mallard. They signify that there was a blank
        # line in the code there.
        text.gsub! '</p>', "\n"
        # Remove any other HTML markup (<> in the code will be escaped)
        text.gsub!(/<.*?>/, '')

        "<pre><code#{language}>#{text}</code></pre>"
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
