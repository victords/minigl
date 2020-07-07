module MiniGL
  # This class represents a font and exposes most of the methods from +Gosu::Font+,
  # but allows the font to be created from an image, allowing for better customization
  # and also using the +retro+ option.
  #
  # The image used to load the font must meet these criteria:
  # * The characters should be laid out in lines of the same height in pixels.
  # * The full image must have a height that is a multiple of that line height.
  # * The characters should occupy the maximum available space in each line, i.e.,
  #   if a character fits in the current line it must not be placed in the next
  #   one. In the last line there can be any amount of free space at the end.
  class ImageFont
    # The height of this font in pixels.
    attr_reader :height

    # Creates an +ImageFont+.
    #
    # Parameters:
    # [img_path] Identifier of an image fitting the description in the class documentation,
    #            as used in +Res.img+.
    # [chars] A string containing all characters that will be present in the image, in the
    #         same order as they appear in the image. Do not include white space.
    # [widths] An integer representing the width of the chars in pixels, if this is a fixed
    #          width font, or an array containing the width of each char, in the same order
    #          as they appear in the +chars+ string.
    # [height] The height of the lines in the image (see description above).
    # [space_width] The width of the white space character in this font.
    # [global] Parameter that will be passed to +Res.img+ when loading the image.
    # [ext] Parameter that will be passed to +Res.img+ when loading the image.
    # [retro] Parameter that will be passed to +Res.img+ when loading the image.
    def initialize(img_path, chars, widths, height, space_width, global = true, ext = '.png', retro = nil)
      retro = Res.retro_images if retro.nil?
      img = Res.img(img_path, global, false, ext, retro)
      @chars = chars
      @images = []
      @height = height
      @space_width = space_width
      wa = widths.is_a?(Array)
      if wa && widths.length != chars.length
        raise 'Wrong widths array size!'
      end
      x = y = 0
      (0...chars.length).each do |i|
        @images.push(img.subimage(x, y, wa ? widths[i] : widths, height))
        new_x = x + (wa ? widths[i] : widths)
        if i < chars.length - 1 && new_x + (wa ? widths[i+1] : widths) > img.width
          x = 0
          y += height
        else
          x = new_x
        end
      end
    end

    # Returns the width, in pixels, of a given string written by this font.
    #
    # Parameters:
    # [text] The string to be measured
    def markup_width(text)
      text.chars.reduce(0) { |w, c| if c == ' '; w += @space_width; else; i = @chars.index(c); w += i ? @images[i].width : 0; end }
    end

    # See <code>Gosu::Font#draw_markup_rel</code> for details.
    def draw_markup_rel(text, x, y, z, rel_x, rel_y, scale_x, scale_y, color)
      text = text.to_s unless text.is_a?(String)
      if rel_x == 0.5
        x -= scale_x * markup_width(text) / 2
      elsif rel_x == 1
        x -= scale_x * markup_width(text)
      end
      if rel_y == 0.5
        y -= scale_y * @height / 2
      elsif rel_y == 1
        y -= scale_x * @height
      end
      text.each_char do |c|
        if c == ' '
          x += scale_x * @space_width
          next
        end
        i = @chars.index(c)
        next if i.nil?
        @images[i].draw(x, y, z, scale_x, scale_y, color)
        x += scale_x * @images[i].width
      end
    end

    # See <code>Gosu::Font#draw_markup</code> for details.
    def draw_markup(text, x, y, z, scale_x, scale_y, color)
      draw_markup_rel(text, x, y, z, 0, 0, scale_x, scale_y, color)
    end

    alias :draw_text_rel :draw_markup_rel
    alias :draw_text :draw_markup
    alias :text_width :markup_width
  end

  # This class provides methods for easily drawing one or multiple lines of
  # text, with control over the text alignment and coloring.
  class TextHelper
    # Creates a TextHelper.
    #
    # Parameters:
    # [font] A <code>Gosu::Font</code> that will be used to draw the text.
    # [line_spacing] When drawing multiple lines, the distance, in pixels,
    #                between each line.
    def initialize(font, line_spacing = 0, scale_x = 1, scale_y = 1)
      @font = font
      @line_spacing = line_spacing
      @scale_x = scale_x
      @scale_y = scale_y
    end

    # Draws a single line of text.
    #
    # Parameters:
    # [text] The text to be drawn. No line breaks are allowed. You can use the
	#        `<b>` tag for bold, `<i>` for italic and `<c=rrggbb>` for colors.
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
    # [effect] Effect to add to the text. It can be either +nil+, for no effect,
    #          +:border+ for bordered text, or +:shadow+ for shadowed text (the
    #          shadow is always placed below and to the right of the text).
    # [effect_color] Color of the effect, if any.
    # [effect_size] Size of the effect, if any. In the case of +:border+, this
    #               will be the width of the border (the border will only look
    #               good when +effect_size+ is relatively small, compared to the
    #               size of the font); in the case of +:shadow+, it will be the
    #               distance between the text and the shadow.
    # [effect_alpha] Opacity of the effect, if any. For shadows, it is usual to
    #                provide less than 255.
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    #
    # *Obs.:* This method accepts named parameters, but +text+, +x+ and +y+ are
    # mandatory.
    def write_line(text, x = nil, y = nil, mode = :left, color = 0, alpha = 0xff,
                   effect = nil, effect_color = 0, effect_size = 1, effect_alpha = 0xff,
                   z_index = 0, scale_x = nil, scale_y = nil)
      if text.is_a? Hash
        x = text[:x]
        y = text[:y]
        mode = text.fetch(:mode, :left)
        color = text.fetch(:color, 0)
        alpha = text.fetch(:alpha, 0xff)
        effect = text.fetch(:effect, nil)
        effect_color = text.fetch(:effect_color, 0)
        effect_size = text.fetch(:effect_size, 1)
        effect_alpha = text.fetch(:effect_alpha, 0xff)
        z_index = text.fetch(:z_index, 0)
        scale_x = text.fetch(:scale_x, nil)
        scale_y = text.fetch(:scale_y, nil)
        text = text[:text]
      end

      scale_x = @scale_x if scale_x.nil?
      scale_y = @scale_y if scale_y.nil?
      color = (alpha << 24) | color
      rel =
        case mode
        when :left then 0
        when :center then 0.5
        when :right then 1
        else 0
        end
      if effect
        effect_color = (effect_alpha << 24) | effect_color
        if effect == :border
          @font.draw_markup_rel text, x - effect_size, y - effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x, y - effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x + effect_size, y - effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x + effect_size, y, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x + effect_size, y + effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x, y + effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x - effect_size, y + effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
          @font.draw_markup_rel text, x - effect_size, y, z_index, rel, 0, scale_x, scale_y, effect_color
        elsif effect == :shadow
          @font.draw_markup_rel text, x + effect_size, y + effect_size, z_index, rel, 0, scale_x, scale_y, effect_color
        end
      end
      @font.draw_markup_rel text, x, y, z_index, rel, 0, scale_x, scale_y, color
    end

    # Draws text, breaking lines when needed and when explicitly caused by the
    # "\n" character.
    #
    # Parameters:
    # [text] The text to be drawn. Line breaks are allowed. You can use the
	  #        `<b>` tag for bold, `<i>` for italic and `<c=rrggbb>` for colors.
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
    def write_breaking(text, x, y, width, mode = :left, color = 0, alpha = 0xff, z_index = 0, scale_x = nil, scale_y = nil, line_spacing = nil)
      line_spacing = @line_spacing if line_spacing.nil?
      scale_x = @scale_x if scale_x.nil?
      scale_y = @scale_y if scale_y.nil?
      color = (alpha << 24) | color
      text.split("\n").each do |p|
        if mode == :justified
          y = write_paragraph_justified p, x, y, width, color, z_index, scale_x, scale_y, line_spacing
        else
          rel =
            case mode
            when :left then 0
            when :center then 0.5
            when :right then 1
            else 0
            end
          y = write_paragraph p, x, y, width, rel, color, z_index, scale_x, scale_y, line_spacing
        end
      end
    end

  private

    def write_paragraph(text, x, y, width, rel, color, z_index, scale_x, scale_y, line_spacing)
      line = ''
      line_width = 0
      text.split(' ').each do |word|
        w = @font.markup_width(word)
        if line_width + w * scale_x > width
          @font.draw_markup_rel line.chop, x, y, z_index, rel, 0, scale_x, scale_y, color
          line = ''
          line_width = 0
          y += (@font.height + line_spacing) * scale_y
        end
        line += "#{word} "
        line_width += @font.markup_width("#{word} ") * scale_x
      end
      @font.draw_markup_rel line.chop, x, y, z_index, rel, 0, scale_x, scale_y, color unless line.empty?
      y + (@font.height + line_spacing) * scale_y
    end

    def write_paragraph_justified(text, x, y, width, color, z_index, scale_x, scale_y, line_spacing)
      space_width = @font.text_width(' ') * scale_x
      spaces = [[]]
      line_index = 0
      new_x = x
      words = text.split(' ')
      words.each do |word|
        w = @font.markup_width(word)
        if new_x + w * scale_x > x + width
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
        new_x += @font.markup_width(word) * scale_x + space_width
        spaces[line_index] << space_width
      end

      index = 0
      spaces.each do |line|
        new_x = x
        line.each do |s|
          @font.draw_markup(words[index], new_x, y, z_index, scale_x, scale_y, color)
          new_x += @font.markup_width(words[index]) * scale_x + s
          index += 1
        end
        y += (@font.height + line_spacing) * scale_y
      end
      y
    end
  end
end
