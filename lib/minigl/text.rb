module AGL
  # This class provides methods for easily drawing one or multiple lines of
  # text, with control over the text alignment and coloring.
  class TextHelper
    # Creates a TextHelper.
    #
    # Parameters:
    # [font] A <code>Gosu::Font</code> that will be used to draw the text.
    # [line_spacing] When drawing multiple lines, the distance, in pixels,
    #                between each line.
    def initialize font, line_spacing = 0
      @font = font
      @line_spacing = line_spacing
    end

    # Draws a single line of text.
    #
    # Parameters:
    # [text] The text to be drawn. No line breaks are allowed.
    # [x] The horizontal reference for drawing the text. If +mode+ is +:left+,
    #     all text will be drawn from this point to the right; if +mode+ is
    #     +:right+, all text will be drawn from this point to the left; and if
    #     +mode+ is +:center+, the text will be equally distributed to the
    #     left and to the right of this point.
    # [y] The vertical reference for drawing the text. All text will be drawn
    #     from this point down.
    # [mode] The alignment of the text. Valid values are +:left+, +:right+ and
    #        +:center+.
    # [color] The color of the text, in hexadecimal RRGGBB format.
    # [alpha] The opacity of the text. Valid values vary from 0 (fully
    #         transparent) to 255 (fully opaque).
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    def write_line text, x, y, mode = :left, color = 0, alpha = 0xff, z_index = 0
      color = (alpha << 24) | color
      rel =
        case mode
        when :left then 0
        when :center then 0.5
        when :right then 1
        else 0
        end
      @font.draw_rel text, x, y, z_index, rel, 0, 1, 1, color
    end

    # Draws text, breaking lines when needed and when explicitly caused by the
    # "\n" character.
    #
    # Parameters:
    # [text] The text to be drawn. Line breaks are allowed.
    # [x] The horizontal reference for drawing the text. Works like in
    #     +write_line+ for the +:left+, +:right+ and +:center+ modes. For the
    #     +:justified+ mode, works the same as for +:left+.
    # [y] The vertical reference for drawing the text. All text will be drawn
    #     from this point down.
    # [width] The maximum width for the lines of text. Line is broken when
    #         this width is exceeded.
    # [mode] The alignment of the text. Valid values are +:left+, +:right+,
    #        +:center+ and +:justified+.
    # [color] The color of the text, in hexadecimal RRGGBB format.
    # [alpha] The opacity of the text. Valid values vary from 0 (fully
    #         transparent) to 255 (fully opaque).
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    def write_breaking text, x, y, width, mode = :left, color = 0, alpha = 0xff, z_index = 0
      color = (alpha << 24) | color
      text.split("\n").each do |p|
        if mode == :justified
          y = write_paragraph_justified p, x, y, width, color, z_index
        else
          rel =
            case mode
            when :left then 0
            when :center then 0.5
            when :right then 1
            else 0
            end
          y = write_paragraph p, x, y, width, rel, color, z_index
        end
      end
    end

  private

    def write_paragraph text, x, y, width, rel, color, z_index
      line = ""
      line_width = 0
      text.split(' ').each do |word|
        w = @font.text_width word
        if line_width + w > width
          @font.draw_rel line.chop, x, y, z_index, rel, 0, 1, 1, color
          line = ""
          line_width = 0
          y += @font.height + @line_spacing
        end
        line += "#{word} "
        line_width += @font.text_width "#{word} "
      end
      @font.draw_rel line.chop, x, y, z_index, rel, 0, 1, 1, color unless line.empty?
      y + @font.height + @line_spacing
    end

    def write_paragraph_justified text, x, y, width, color, z_index
      space_width = @font.text_width " "
      spaces = [[]]
      line_index = 0
      new_x = x
      words = text.split(' ')
      words.each do |word|
        w = @font.text_width word
        if new_x + w > x + width
          space = x + width - new_x + space_width
          index = 0
          while space > 0
            spaces[line_index][index] += 1
            space -= 1
            index += 1
            index = 0 if index == spaces[line_index].size - 1
          end

          spaces << []
          line_index += 1

          new_x = x
        end
        new_x += @font.text_width(word) + space_width
        spaces[line_index] << space_width
      end

      index = 0
      spaces.each do |line|
        new_x = x
        line.each do |s|
          @font.draw words[index], new_x, y, z_index, 1, 1, color
          new_x += @font.text_width(words[index]) + s
          index += 1
        end
        y += @font.height + @line_spacing
      end
      y
    end
  end
end
