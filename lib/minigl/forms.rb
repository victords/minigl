require_relative 'global'

module MiniGL
  # This class is an abstract ancestor for all form components (Button,
  # ToggleButton and TextField).
  class Component
    # The horizontal coordinate of the component
    attr_reader :x

    # The vertical coordinate of the component
    attr_reader :y

    # The width of the component
    attr_reader :w

    # The height of the component
    attr_reader :h

    # Determines whether the control is enabled, i.e., will process user input.
    attr_accessor :enabled

    # Determines whether the control is visible, i.e., will be drawn in the
    # screen and process user input, if enabled.
    attr_accessor :visible

    # A container for any parameters to be passed to the code blocks called
    # in response to events of the control (click of a button, change of the
    # text in a text field, etc.). More detail can be found in the constructor
    # for each specific component class.
    attr_accessor :params

    # This constructor is for internal use of the subclasses only. Do not
    # instantiate objects of this class.
    def initialize(x, y, font, text, text_color, disabled_text_color)
      @x = x
      @y = y
      @font = font
      @text = text
      @text_color = text_color
      @disabled_text_color = disabled_text_color
      @enabled = @visible = true
    end
  end

  # This class represents a button.
  class Button < Component
    # The current state of the button.
    attr_reader :state

    # The text of the button.
    attr_accessor :text

    # Creates a button.
    #
    # Parameters:
    # [x] The x-coordinate where the button will be drawn in the screen.
    # [y] The y-coordinate where the button will be drawn in the screen.
    # [font] The <code>Gosu::Font</code> object that will be used to draw the
    #        button text.
    # [text] The button text. Can be +nil+ or empty.
    # [img] A spritesheet containing four images in a column, representing,
    #       from top to bottom, the default state, the hover state (when the
    #       mouse is over the button), the pressed state (when the mouse
    #       button is down and the cursor is over the button) and the disabled
    #       state. If +nil+, the +width+ and +height+ parameters must be
    #       provided.
    # [text_color] Color of the button text, in hexadecimal RRGGBB format.
    # [disabled_text_color] Color of the button text, when it's disabled, in
    #                       hexadecimal RRGGBB format.
    # [over_text_color] Color of the button text, when the cursor is over it
    #                   (hexadecimal RRGGBB).
    # [down_text_color] Color of the button text, when it is pressed
    #                   (hexadecimal RRGGBB).
    # [center_x] Whether the button text should be horizontally centered in its
    #            area (the area is defined by the image size, if an image is
    #            given, or by the +width+ and +height+ parameters, otherwise).
    # [center_y] Whether the button text should be vertically centered in its
    #            area (the area is defined by the image size, if an image is
    #            given, or by the +width+ and +height+ parameters, otherwise).
    # [margin_x] The x offset, from the button x-coordinate, to draw the text.
    #            This parameter is used only if +center+ is false.
    # [margin_y] The y offset, from the button y-coordinate, to draw the text.
    #            This parameter is used only if +center+ is false.
    # [width] Width of the button clickable area. This parameter is used only
    #         if +img+ is +nil+.
    # [height] Height of the button clickable area. This parameter is used
    #          only if +img+ is +nil+.
    # [params] An object containing any parameters you want passed to the
    #          +action+ block. When the button is clicked, the following is
    #          called:
    #            @action.call @params
    #          Note that this doesn't force you to declare a block that takes
    #          parameters.
    # [action] The block of code executed when the button is clicked (or by
    #          calling the +click+ method).
    def initialize(x, y, font, text, img, text_color = 0, disabled_text_color = 0, over_text_color = 0, down_text_color = 0,
                   center_x = true, center_y = true, margin_x = 0, margin_y = 0, width = nil, height = nil, params = nil, &action)
      super x, y, font, text, text_color, disabled_text_color
      @over_text_color = over_text_color
      @down_text_color = down_text_color
      @img =
        if img; Res.imgs img, 1, 4, true
        else; nil; end
      @w =
        if img; @img[0].width
        else; width; end
      @h =
        if img; @img[0].height
        else; height; end
      if center_x; @text_x = x + @w / 2 if @w
      else; @text_x = x + margin_x; end
      if center_y; @text_y = y + @h / 2 if @h
      else; @text_y = y + margin_y; end
      @center_x = center_x
      @center_y = center_y
      @action = action
      @params = params

      @state = :up
      @img_index = @enabled ? 0 : 3
    end

    # Updates the button, checking the mouse movement and buttons to define
    # the button state.
    def update
      return unless @enabled and @visible

      mouse_over = Mouse.over? @x, @y, @w, @h
      mouse_press = Mouse.button_pressed? :left
      mouse_rel = Mouse.button_released? :left

      if @state == :up
        if mouse_over
          @img_index = 1
          @state = :over
        else
          @img_index = 0
        end
      elsif @state == :over
        if not mouse_over
          @img_index = 0
          @state = :up
        elsif mouse_press
          @img_index = 2
          @state = :down
        else
          @img_index = 1
        end
      elsif @state == :down
        if not mouse_over
          @img_index = 0
          @state = :down_out
        elsif mouse_rel
          @img_index = 1
          @state = :over
          click
        else
          @img_index = 2
        end
      else # :down_out
        if mouse_over
          @img_index = 2
          @state = :down
        elsif mouse_rel
          @img_index = 0
          @state = :up
        else
          @img_index = 0
        end
      end
    end

    # Executes the button click action.
    def click
      @action.call @params
    end

    # Sets the position of the button in the screen.
    #
    # Parameters:
    # [x] The new x-coordinate for the button.
    # [y] The new y-coordinate for the button.
    def set_position(x, y)
      if @center_x; @text_x = x + @w / 2
      else; @text_x += x - @x; end
      if @center_y; @text_y = y + @h / 2
      else; @text_y += y - @y; end
      @x = x; @y = y
    end

    # Draws the button in the screen.
    #
    # Parameters:
    # [alpha] The opacity with which the button will be drawn. Allowed values
    #         vary between 0 (fully transparent) and 255 (fully opaque).
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    def draw(alpha = 0xff, z_index = 0)
      return unless @visible

      color = (alpha << 24) | 0xffffff
      text_color =
        if @enabled
          if @state == :down
            @down_text_color
          else
            @state == :over ? @over_text_color : @text_color
          end
        else
          @disabled_text_color
        end
      text_color = (alpha << 24) | text_color
      @img[@img_index].draw @x, @y, z_index, 1, 1, color if @img
      if @text
        if @center_x or @center_y
          rel_x = @center_x ? 0.5 : 0
          rel_y = @center_y ? 0.5 : 0
          @font.draw_rel @text, @text_x, @text_y, z_index, rel_x, rel_y, 1, 1, text_color
        else
          @font.draw @text, @text_x, @text_y, z_index, 1, 1, text_color
        end
      end
    end

    def enabled=(value) # :nodoc:
      @enabled = value
      @state = :up
      @img_index = 3
    end
  end

  # This class represents a toggle button, which can be also interpreted as a
  # check box. It is always in one of two states, given as +true+ or +false+
  # by its property +checked+.
  class ToggleButton < Button
    # Defines the state of the button (returns +true+ or +false+).
    attr_reader :checked

    # Creates a ToggleButton. All parameters work the same as in Button,
    # except for the image, +img+, which now has to be composed of two columns
    # and four rows, the first column with images for the unchecked state,
    # and the second with images for the checked state, and for +checked+,
    # which defines the initial state of the ToggleButton.
    #
    # The +action+ block now will always receive a first boolean parameter
    # corresponding to the value of +checked+. So, if you want to pass
    # parameters to the block, you should declare it like this:
    #   b = ToggleButton.new ... { |checked, params|
    #     puts "button was checked" if checked
    #     # do something with params
    #   }
    def initialize(x, y, font, text, img, checked = false, text_color = 0, disabled_text_color = 0, over_text_color = 0, down_text_color = 0,
                   center_x = true, center_y = true, margin_x = 0, margin_y = 0, width = nil, height = nil, params = nil, &action)
      super x, y, font, text, nil, text_color, disabled_text_color, over_text_color, down_text_color,
            center_x, center_y, margin_x, margin_y, width, height, params, &action
      @img =
        if img; Res.imgs img, 2, 4, true
        else; nil; end
      @w =
        if img; @img[0].width
        else; width; end
      @h =
        if img; @img[0].height
        else; height; end
      @text_x = x + @w / 2 if center_x
      @text_y = y + @h / 2 if center_y
      @checked = checked
    end

    # Updates the button, checking the mouse movement and buttons to define
    # the button state.
    def update
      return unless @enabled and @visible

      super
      @img_index *= 2
      @img_index += 1 if @checked
    end

    # Executes the button click action, and toggles its state. The +action+
    # block always receives as a first parameter +true+, if the button has
    # been changed to checked, or +false+, otherwise.
    def click
      @checked = !@checked
      @action.call @checked, @params
    end

    # Sets the state of the button to the value given.
    #
    # Parameters:
    # [value] The state to be set (+true+ for checked, +false+ for unchecked).
    def checked=(value)
      click if value != @checked
      @checked = value
    end

    def enabled=(value) # :nodoc:
      @enabled = value
      @state = :up
      @img_index = @checked ? 7 : 6
    end
  end

  # This class represents a text field (input).
  class TextField < Component
    # The current text inside the text field.
    attr_reader :text

    # The current 'locale' used for detecting the keys. THIS FEATURE IS
    # INCOMPLETE!
    attr_reader :locale

    # Creates a new text field.
    #
    # Parameters:
    # [x] The x-coordinate where the text field will be drawn in the screen.
    # [y] The y-coordinate where the text field will be drawn in the screen.
    # [font] The <code>Gosu::Font</code> object that will be used to draw the
    #        text inside the field.
    # [img] The image of the text field. For a good result, you would likely
    #       want something like a rectangle, horizontally wide, vertically
    #       short, and with a color that contrasts with the +text_color+.
    # [cursor_img] An image for the blinking cursor that stands in the point
    #              where text will be inserted. If +nil+, a simple black line
    #              will be drawn instead.
    # [disabled_img] Image for the text field when it's disabled. If +nil+,
    #                a darkened version of +img+ will be used.
    # [text_color] Color of the button text, in hexadecimal RRGGBB format.
    # [margin_x] The x offset, from the field x-coordinate, to draw the text.
    # [margin_y] The y offset, from the field y-coordinate, to draw the text.
    # [max_length] The maximum length of the text inside the field.
    # [active] Whether the text field must be focused by default. If +false+,
    #          focus can be granted by clicking inside the text field or by
    #          calling the +focus+ method.
    # [text] The starting text. Must not be +nil+.
    # [allowed_chars] A string containing all characters that can be typed
    #                 inside the text field. The complete set of supported
    #                 characters is given by the string
    #                 <code>"abcdefghijklmnopqrstuvwxyz1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ'-=/[]\\\\,.;\"_+?{}|<>:!@#$%¨&*()"</code>.
    # [text_color] The color with which the text will be drawn, in hexadecimal
    #              RRGGBB format.
    # [disabled_text_color] The color with which the text will be drawn, when
    #                       the text field is disabled, in hexadecimal RRGGBB
    #                       format.
    # [selection_color] The color of the rectangle highlighting selected text,
    #                   in hexadecimal RRGGBB format. The rectangle will
    #                   always be drawn with 50% of opacity.
    # [locale] The locale to be used when detecting keys. By now, only 'en-US'
    #          and 'pt-BR' are **partially** supported. Default is 'en-US'. If
    #          any different value is supplied, all typed characters will be
    #          mapped to '#'.
    # [params] An object containing any parameters you want passed to the
    #          +on_text_changed+ block. When the text of the text field is
    #          changed, the following is called:
    #            @on_text_changed.call @text, @params
    #          Thus, +params+ will be the second parameter. Note that this
    #          doesn't force you to declare a block that takes parameters.
    # [on_text_changed] The block of code executed when the text in the text
    #                   field is changed, either by user input or by calling
    #                   +text=+. The new text is passed as a first parameter
    #                   to this block, followed by +params+. Can be +nil+.
    def initialize(x, y, font, img, cursor_img = nil, disabled_img = nil, margin_x = 0, margin_y = 0, max_length = 100, active = false, text = '',
                   allowed_chars = nil, text_color = 0, disabled_text_color = 0, selection_color = 0, locale = 'en-us', params = nil, &on_text_changed)
      super x, y, font, text, text_color, disabled_text_color
      @img = Res.img img
      @w = @img.width
      @h = @img.height
      @cursor_img = Res.img(cursor_img) if cursor_img
      @disabled_img = Res.img(disabled_img) if disabled_img
      @max_length = max_length
      @active = active
      @text_x = x + margin_x
      @text_y = y + margin_y
      @selection_color = selection_color

      @nodes = [x + margin_x]
      @cur_node = 0
      @cursor_visible = false
      @cursor_timer = 0

      @k = [
        Gosu::KbA, Gosu::KbB, Gosu::KbC, Gosu::KbD, Gosu::KbE, Gosu::KbF,
        Gosu::KbG, Gosu::KbH, Gosu::KbI, Gosu::KbJ, Gosu::KbK, Gosu::KbL,
        Gosu::KbM, Gosu::KbN, Gosu::KbO, Gosu::KbP, Gosu::KbQ, Gosu::KbR,
        Gosu::KbS, Gosu::KbT, Gosu::KbU, Gosu::KbV, Gosu::KbW, Gosu::KbX,
        Gosu::KbY, Gosu::KbZ, Gosu::Kb1, Gosu::Kb2, Gosu::Kb3, Gosu::Kb4,
        Gosu::Kb5, Gosu::Kb6, Gosu::Kb7, Gosu::Kb8, Gosu::Kb9, Gosu::Kb0,
        Gosu::KbNumpad1, Gosu::KbNumpad2, Gosu::KbNumpad3, Gosu::KbNumpad4,
        Gosu::KbNumpad5, Gosu::KbNumpad6, Gosu::KbNumpad7, Gosu::KbNumpad8,
        Gosu::KbNumpad9, Gosu::KbNumpad0, Gosu::KbSpace, Gosu::KbBackspace,
        Gosu::KbDelete, Gosu::KbLeft, Gosu::KbRight, Gosu::KbHome,
        Gosu::KbEnd, Gosu::KbLeftShift, Gosu::KbRightShift,
        Gosu::KbBacktick, Gosu::KbMinus, Gosu::KbEqual, Gosu::KbBracketLeft,
        Gosu::KbBracketRight, Gosu::KbBackslash, Gosu::KbSemicolon,
        Gosu::KbApostrophe, Gosu::KbComma, Gosu::KbPeriod, Gosu::KbSlash,
        Gosu::KbNumpadAdd, Gosu::KbNumpadSubtract,
        Gosu::KbNumpadMultiply, Gosu::KbNumpadDivide
      ]
      @user_allowed_chars = allowed_chars
      self.locale = locale

      @on_text_changed = on_text_changed
      @params = params
    end

    # Updates the text field, checking for mouse events and keyboard input.
    def update
      return unless @enabled and @visible

      ################################ Mouse ################################
      if Mouse.over? @x, @y, @w, @h
        if not @active and Mouse.button_pressed? :left
          focus
        end
      elsif Mouse.button_pressed? :left
        unfocus
      end

      return unless @active

      if Mouse.double_click? :left
        if @nodes.size > 1
          @anchor1 = 0
          @anchor2 = @nodes.size - 1
          @cur_node = @anchor2
          @double_clicked = true
        end
        set_cursor_visible
      elsif Mouse.button_pressed? :left
        set_node_by_mouse
        @anchor1 = @cur_node
        @anchor2 = nil
        @double_clicked = false
        set_cursor_visible
      elsif Mouse.button_down? :left
        if @anchor1 and not @double_clicked
          set_node_by_mouse
          if @cur_node != @anchor1; @anchor2 = @cur_node
          else; @anchor2 = nil; end
          set_cursor_visible
        end
      elsif Mouse.button_released? :left
        if @anchor1 and not @double_clicked
          if @cur_node != @anchor1; @anchor2 = @cur_node
          else; @anchor1 = nil; end
        end
      end

      @cursor_timer += 1
      if @cursor_timer >= 30
        @cursor_visible = (not @cursor_visible)
        @cursor_timer = 0
      end

      ############################### Keyboard ##############################
      shift = (KB.key_down?(@k[53]) or KB.key_down?(@k[54]))
      if KB.key_pressed?(@k[53]) or KB.key_pressed?(@k[54]) # shift
        @anchor1 = @cur_node if @anchor1.nil?
      elsif KB.key_released?(@k[53]) or KB.key_released?(@k[54])
        @anchor1 = nil if @anchor2.nil?
      end
      inserted = false
      for i in 0..46 # alnum
        if KB.key_pressed?(@k[i]) or KB.key_held?(@k[i])
          remove_interval true if @anchor1 and @anchor2
          if i < 26
            if shift
              insert_char @chars[i + 37]
            else
              insert_char @chars[i]
            end
          elsif i < 36
            if shift; insert_char @chars[i + 59]
            else; insert_char @chars[i]; end
          elsif shift
            insert_char(@chars[i + 49])
          else
            insert_char(@chars[i - 10])
          end
          inserted = true
          break
        end
      end

      return if inserted
      for i in 55..65 # special
        if KB.key_pressed?(@k[i]) or KB.key_held?(@k[i])
          remove_interval true if @anchor1 and @anchor2
          if shift; insert_char @chars[i + 19]
          else; insert_char @chars[i + 8]; end
          inserted = true
          break
        end
      end

      return if inserted
      for i in 66..69 # numpad operators
        if KB.key_pressed?(@k[i]) or KB.key_held?(@k[i])
          remove_interval true if @anchor1 and @anchor2
          insert_char @chars[i + 19]
          inserted = true
          break
        end
      end

      return if inserted
      if KB.key_pressed?(@k[47]) or KB.key_held?(@k[47]) # back
        if @anchor1 and @anchor2
          remove_interval
        elsif @cur_node > 0
          remove_char true
        end
      elsif KB.key_pressed?(@k[48]) or KB.key_held?(@k[48]) # del
        if @anchor1 and @anchor2
          remove_interval
        elsif @cur_node < @nodes.size - 1
          remove_char false
        end
      elsif KB.key_pressed?(@k[49]) or KB.key_held?(@k[49]) # left
        if @anchor1
          if shift
            if @cur_node > 0
              @cur_node -= 1
              @anchor2 = @cur_node
              set_cursor_visible
            end
          elsif @anchor2
            @cur_node = @anchor1 < @anchor2 ? @anchor1 : @anchor2
            @anchor1 = nil
            @anchor2 = nil
            set_cursor_visible
          end
        elsif @cur_node > 0
          @cur_node -= 1
          set_cursor_visible
        end
      elsif KB.key_pressed?(@k[50]) or KB.key_held?(@k[50]) # right
        if @anchor1
          if shift
            if @cur_node < @nodes.size - 1
              @cur_node += 1
              @anchor2 = @cur_node
              set_cursor_visible
            end
          elsif @anchor2
            @cur_node = @anchor1 > @anchor2 ? @anchor1 : @anchor2
            @anchor1 = nil
            @anchor2 = nil
            set_cursor_visible
          end
        elsif @cur_node < @nodes.size - 1
          @cur_node += 1
          set_cursor_visible
        end
      elsif KB.key_pressed?(@k[51]) # home
        @cur_node = 0
        if shift; @anchor2 = @cur_node
        else
          @anchor1 = nil
          @anchor2 = nil
        end
        set_cursor_visible
      elsif KB.key_pressed?(@k[52]) # end
        @cur_node = @nodes.size - 1
        if shift; @anchor2 = @cur_node
        else
          @anchor1 = nil
          @anchor2 = nil
        end
        set_cursor_visible
      end
    end

    # Sets the text of the text field to the specified value.
    #
    # Parameters:
    # [value] The new text to be set. If it's longer than the +max_length+
    #         parameter used in the constructor, it will be truncated to
    #         +max_length+ characters.
    def text=(value)
      @text = value[0...@max_length]
      @nodes.clear; @nodes << @text_x
      x = @nodes[0]
      @text.chars.each { |char|
        x += @font.text_width char
        @nodes << x
      }
      @cur_node = @nodes.size - 1
      @anchor1 = nil
      @anchor2 = nil
      set_cursor_visible
      @on_text_changed.call @text, @params if @on_text_changed
    end

    # Sets the locale used by the text field to detect keys. Only 'en-us' and
    # 'pt-br' are **partially** supported. If any different value is supplied,
    # all typed characters will be mapped to '#'.
    def locale=(value)
      @locale = value.downcase
      @chars =
          case @locale
            when 'en-us' then "abcdefghijklmnopqrstuvwxyz1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ`-=[]\\;',./~_+{}|:\"<>?!@#$%^&*()+-*/"
            when 'pt-br' then "abcdefghijklmnopqrstuvwxyz1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ'-=/[]ç~,.;\"_+?{}Ç^<>:!@#$%¨&*()+-*/"
            else              '###################################################################################################'
          end
      @allowed_chars =
          if @user_allowed_chars
            @user_allowed_chars
          else
            @chars
          end
    end

    # Returns the currently selected text.
    def selected_text
      return '' if @anchor2.nil?
      min = @anchor1 < @anchor2 ? @anchor1 : @anchor2
      max = min == @anchor1 ? @anchor2 : @anchor1
      @text[min..max]
    end

    # Grants focus to the text field, so that it allows keyboard input.
    def focus
      @active = true
    end

    # Removes focus from the text field, so that no keyboard input will be
    # accepted.
    def unfocus
      @anchor1 = @anchor2 = nil
      @cursor_visible = false
      @cursor_timer = 0
      @active = false
    end

    # Sets the position of the text field in the screen.
    #
    # Parameters:
    # [x] The new x-coordinate for the text field.
    # [y] The new y-coordinate for the text field.
    def set_position(x, y)
      d_x = x - @x
      d_y = y - @y
      @x = x; @y = y
      @text_x += d_x
      @text_y += d_y
      @nodes.map! do |n|
        n + d_x
      end
    end

    # Draws the text field in the screen.
    #
    # Parameters:
    # [alpha] The opacity with which the text field will be drawn. Allowed
    #         values vary between 0 (fully transparent) and 255 (fully opaque).
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    def draw(alpha = 0xff, z_index = 0)
      return unless @visible

      color = (alpha << 24) | ((@enabled or @disabled_img) ? 0xffffff : 0x808080)
      text_color = (alpha << 24) | (@enabled ? @text_color : @disabled_text_color)
      img = ((@enabled or @disabled_img.nil?) ? @img : @disabled_img)
      img.draw @x, @y, z_index, 1, 1, color
      @font.draw @text, @text_x, @text_y, z_index, 1, 1, text_color

      if @anchor1 and @anchor2
        selection_color = ((alpha / 2) << 24) | @selection_color
        G.window.draw_quad @nodes[@anchor1], @text_y, selection_color,
                           @nodes[@anchor2] + 1, @text_y, selection_color,
                           @nodes[@anchor2] + 1, @text_y + @font.height, selection_color,
                           @nodes[@anchor1], @text_y + @font.height, selection_color, z_index
      end

      if @cursor_visible
        if @cursor_img
          @cursor_img.draw @nodes[@cur_node] - @cursor_img.width / 2, @text_y, z_index
        else
          cursor_color = alpha << 24
          G.window.draw_quad @nodes[@cur_node], @text_y, cursor_color,
                             @nodes[@cur_node] + 1, @text_y, cursor_color,
                             @nodes[@cur_node] + 1, @text_y + @font.height, cursor_color,
                             @nodes[@cur_node], @text_y + @font.height, cursor_color, z_index
        end
      end
    end

    def enabled=(value) # :nodoc:
      @enabled = value
      unfocus unless @enabled
    end

    def visible=(value) # :nodoc:
      @visible = value
      unfocus unless @visible
    end

  private

    def set_cursor_visible
      @cursor_visible = true
      @cursor_timer = 0
    end

    def set_node_by_mouse
      index = @nodes.size - 1
      @nodes.each_with_index do |n, i|
        if n >= Mouse.x
          index = i
          break
        end
      end
      if index > 0
        d1 = @nodes[index] - Mouse.x; d2 = Mouse.x - @nodes[index - 1]
        index -= 1 if d1 > d2
      end
      @cur_node = index
    end

    def insert_char(char)
      return unless @allowed_chars.index char and @text.length < @max_length
      @text.insert @cur_node, char
      @nodes.insert @cur_node + 1, @nodes[@cur_node] + @font.text_width(char)
      for i in (@cur_node + 2)..(@nodes.size - 1)
        @nodes[i] += @font.text_width(char)
      end
      @cur_node += 1
      set_cursor_visible
      @on_text_changed.call @text, @params if @on_text_changed
    end

    def remove_interval(will_insert = false)
      min = @anchor1 < @anchor2 ? @anchor1 : @anchor2
      max = min == @anchor1 ? @anchor2 : @anchor1
      interval_width = 0
      for i in min...max
        interval_width += @font.text_width(@text[i])
        @nodes.delete_at min + 1
      end
      @text[min...max] = ''
      for i in (min + 1)..(@nodes.size - 1)
        @nodes[i] -= interval_width
      end
      @cur_node = min
      @anchor1 = nil
      @anchor2 = nil
      set_cursor_visible
      @on_text_changed.call @text, @params if @on_text_changed and not will_insert
    end

    def remove_char(back)
      @cur_node -= 1 if back
      char_width = @font.text_width(@text[@cur_node])
      @text[@cur_node] = ''
      @nodes.delete_at @cur_node + 1
      for i in (@cur_node + 1)..(@nodes.size - 1)
        @nodes[i] -= char_width
      end
      set_cursor_visible
      @on_text_changed.call @text, @params if @on_text_changed
    end
  end

  # Represents a progress bar.
  class ProgressBar < Component
    # The maximum value for this progress bar (when the current value equals
    # the maximum, the bar is full).
    attr_reader :max_value

    # The current value of the progress bar (an integer greater than or equal
    # to zero, and less than or equal to +max_value+).
    attr_reader :value

    # Creates a progress bar.
    #
    # Parameters:
    # [x] The x-coordinate of the progress bar on the screen.
    # [y] The y-coordinate of the progress bar on the screen.
    # [w] Width of the progress bar, in pixels. This is the maximum space the
    #     bar foreground can occupy. Note that the width of the foreground image
    #     (+fg+) can be less than this.
    # [h] Height of the progress bar. This will be the height of the bar
    #     foreground when +fg+ is a color (when it is an image, the height of
    #     the image will be kept).
    # [bg] A background image (string or symbol that will be passed to
    #      +Res.img+) or color (in RRGGBB hexadecimal format).
    # [fg] A foreground image (string or symbol that will be passed to
    #      +Res.img+) or color (in RRGGBB hexadecimal format). The image will
    #      be horizontally repeated when needed, if its width is less than +w+.
    # [max_value] The maximum value the progress bar can reach (an integer).
    # [value] The starting value for the progress bar.
    # [fg_margin_x] Horizontal margin between the background image and the
    #               foreground image (when these are provided).
    # [fg_margin_y] Vertical margin between the background image and the
    #               foreground image (when these are provided).
    # [font] Font that will be used to draw a text indicating the value of the
    #        progress bar.
    # [text_color] Color of the text.
    # [format] Format to display the value. Specify '%' for a percentage and
    #          anything else for absolute values (current/maximum).
    def initialize(x, y, w, h, bg, fg, max_value = 100, value = 100, fg_margin_x = 0, fg_margin_y = 0, #fg_left = nil, fg_right = nil,
                   font = nil, text_color = 0, format = nil)
      super x, y, font, '', text_color, text_color
      @w = w
      @h = h
      if bg.is_a? Integer
        @bg_color = bg
      else # String or Symbol
        @bg = Res.img bg
      end
      if fg.is_a? Integer
        @fg_color = fg
      else # String or Symbol
        @fg = Res.img fg
        @fg_path = "#{Res.prefix}#{Res.img_dir}#{fg.to_s.gsub(Res.separator, '/')}.png"
        puts @fg_path
      end
      @fg_margin_x = fg_margin_x
      @fg_margin_y = fg_margin_y
      # @fg_left = fg_left
      # @fg_right = fg_right
      @max_value = max_value
      self.value = value
      @format = format
    end

    # Increases the current value of the progress bar by the given amount.
    #
    # Parameters:
    # [amount] (+Integer+) The amount to be added to the current value. If the
    #          sum surpasses +max_value+, it is set to +max_value+.
    def increase(amount)
      @value += amount
      @value = @max_value if @value > @max_value
    end

    # Descreases the current value of the progress bar by the given amount.
    #
    # Parameters:
    # [amount] (+Integer+) The amount to be subtracted from the current value.
    #          If the result is less than zero, it is set to zero.
    def decrease(amount)
      @value -= amount
      @value = 0 if @value < 0
    end

    # Sets the value of the progress bar.
    #
    # Parameters:
    # [val] (+Integer+) The value to be set. It will be changed as needed to be
    #       between zero and +max_value+.
    def value=(val)
      @value = val
      if @value > @max_value
        @value = @max_value
      elsif @value < 0
        @value = 0
      end
    end

    # Sets the value of the progress bar to a given percentage of +max_value+.
    #
    # Parameters:
    # [pct] (+Numeric+) The percentage of +max_value+ to set the current value
    #       to. The final result will be changed as needed to be between zero
    #       and +max_value+.
    def percentage=(pct)
      self.value = (pct * @max_value).round
    end

    # Draws the progress bar.
    #
    # Parameters:
    # [alpha] (+Fixnum+) The opacity with which the progress bar will be drawn.
    #         Allowed values vary between 0 (fully transparent) and 255 (fully
    #         opaque).
    # [z_index] (+Fixnum+) The z-order to draw the object. Objects with larger
    #           z-orders will be drawn on top of the ones with smaller z-orders.
    def draw(alpha = 0xff, z_index = 0)
      return unless @visible

      if @bg
        c = (alpha << 24) | 0xffffff
        @bg.draw @x, @y, z_index, 1, 1, c
      else
        c = (alpha << 24) | @bg_color
        G.window.draw_quad @x, @y, c,
                           @x + @w, @y, c,
                           @x + @w, @y + @h, c,
                           @x, @y + @h, c, z_index
      end
      if @fg
        c = (alpha << 24) | 0xffffff
        w1 = @fg.width
        w2 = (@value.to_f / @max_value * @w).round
        x0 = @x + @fg_margin_x
        x = 0
        while x <= w2 - w1
          @fg.draw x0 + x, @y + @fg_margin_y, z_index, 1, 1, c
          x += w1
        end
        if w2 - x > 0
          img = Gosu::Image.new(G.window, @fg_path, true, 0, 0, w2 - x, @fg.height)
          img.draw x0 + x, @y + @fg_margin_y, z_index, 1, 1, c
        end
      else
        c = (alpha << 24) | @fg_color
        rect_r = @x + (@value.to_f / @max_value * @w).round
        G.window.draw_quad @x, @y, c,
                           rect_r, @y, c,
                           rect_r, @y + @h, c,
                           @x, @y + @h, c, z_index
      end
      if @font
        c = (alpha << 24) | @text_color
        @text = @format == '%' ? "#{(@value.to_f / @max_value * 100).round}%" : "#{@value}/#{@max_value}"
        @font.draw_rel @text, @x + @fg_margin_x + @w / 2, @y + @fg_margin_y + @h / 2, 0, 0.5, 0.5, 1, 1, c
      end
    end
  end

  # This class represents a "drop-down list" form component, here composed of a
  # group of +Button+ objects.
  class DropDownList < Component
    # The selected value in the drop-down list. This is one of the +options+.
    attr_reader :value

    # An array containing all the options (each of them +String+s) that can be
    # selected in the drop-down list.
    attr_accessor :options

    # Creates a new drop-down list.
    #
    # Parameters:
    # [x] The x-coordinate of the object.
    # [y] The y-coordinate of the object.
    # [font] Font to be used by the buttons that compose the drop-donwn list.
    # [img] Image of the main button, i.e., the one at the top, that toggles
    #       visibility of the other buttons (the "option" buttons).
    # [opt_img] Image for the "option" buttons, as described above.
    # [options] Array of available options for this control (+String+s).
    # [option] Index of the firstly selected option.
    # [text_margin] Left margin of the text inside the buttons (vertically, the
    #               text will always be centered).
    # [width] Width of the control, used when no image is provided.
    # [height] Height of the control, used when no image is provided.
    # [text_color] Used as the +text_color+ parameter in the constructor of the
    #              buttons.
    # [disabled_text_color] Analogous to +text_color+.
    # [over_text_color] Same as above.
    # [down_text_color] Same as above.
    def initialize(x, y, font, img, opt_img, options, option = 0, text_margin = 0, width = nil, height = nil,
                   text_color = 0, disabled_text_color = 0, over_text_color = 0, down_text_color = 0)
      super x, y, font, options[option], text_color, disabled_text_color
      @img = img
      @opt_img = opt_img
      @options = options
      @value = @options[option]
      @open = false
      @buttons = []
      @buttons.push(
        Button.new(x, y, font, @value, img, text_color, disabled_text_color, over_text_color, down_text_color,
                   false, true, text_margin, 0, width, height) {
                     toggle
                   }
      )
      @w = @buttons[0].w
      @h = @buttons[0].h
      @options.each_with_index do |o, i|
        b = Button.new(x, y + (i+1) * @h, font, o, opt_img, text_color, disabled_text_color, over_text_color, down_text_color,
                       false, true, text_margin, 0, @w, @h) {
                         @value = @buttons[0].text = o
                         toggle
                       }
        b.visible = false
        @buttons.push b
      end
      @max_h = (@options.size + 1) * @h
    end

    # Updates the control.
    def update
      return unless @enabled and @visible
      if @open and Mouse.button_pressed? :left and not Mouse.over?(@x, @y, @w, @max_h)
        toggle
        return
      end
      @buttons.each { |b| b.update }
    end

    # Sets the currently selected value of the drop-down list. It is ignored if
    # it is not among the available options.
    def value=(val)
      if @options.include? val
        @value = @buttons[0].text = val
      end
    end

    def enabled=(value) # :nodoc:
      toggle if @open
      @buttons[0].enabled = value
      @enabled = value
    end

    # Draws the drop-down list.
    #
    # Parameters:
    # [alpha] (+Fixnum+) The opacity with which the drop-down list will be
    #         drawn. Allowed values vary between 0 (fully transparent) and 255
    #         (fully opaque).
    # [z_index] (+Fixnum+) The z-order to draw the object. Objects with larger
    #           z-orders will be drawn on top of the ones with smaller z-orders.
    def draw(alpha = 0xff, z_index = 0)
      return unless @visible
      unless @img
        bottom = @open ? @y + @max_h + 1 : @y + @h + 1
        b_color = (alpha << 24)
        G.window.draw_quad @x - 1, @y - 1, b_color,
                           @x + @w + 1, @y - 1, b_color,
                           @x + @w + 1, bottom, b_color,
                           @x - 1, bottom, b_color, z_index
        @buttons.each do |b|
          color = (alpha << 24) | (b.state == :over ? 0xcccccc : 0xffffff)
          G.window.draw_quad b.x, b.y, color,
                             b.x + b.w, b.y, color,
                             b.x + b.w, b.y + b.h, color,
                             b.x, b.y + b.h, color, z_index if b.visible
        end
      end
      @buttons.each { |b| b.draw alpha, z_index }
    end

    private

    def toggle
      if @open
        @buttons[1..-1].each { |b| b.visible = false }
        @open = false
      else
        @buttons[1..-1].each { |b| b.visible = true }
        @open = true
      end
    end
  end
end
