require_relative 'global'

module AGL
  # This class is an abstract ancestor for all form components (Button,
  # ToggleButton and TextField).
  class Component
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
    def initialize(x, y, font, text, img, text_color = 0, disabled_text_color = 0, center_x = true, center_y = true,
                   margin_x = 0, margin_y = 0, width = nil, height = nil, params = nil, &action)
      super x, y, font, text, text_color, disabled_text_color
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
      text_color = (alpha << 24) | (@enabled ? @text_color : @disabled_text_color)
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
    def initialize(x, y, font, text, img, checked = false, text_color = 0, disabled_text_color = 0, center_x = true, center_y = true,
                   margin_x = 0, margin_y = 0, width = nil, height = nil, params = nil, &action)
      super x, y, font, text, nil, text_color, disabled_text_color, center_x, center_y, margin_x, margin_y, width, height, params, &action
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
                   allowed_chars = nil, text_color = 0, disabled_text_color = 0, selection_color = 0, params = nil, &on_text_changed)
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
        Gosu::KbBracketRight, Gosu::KbBackslash, Gosu::KbApostrophe,
        Gosu::KbComma, Gosu::KbPeriod, Gosu::KbSlash
      ]
      @chars = "abcdefghijklmnopqrstuvwxyz1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ'-=/[]\\,.;\"_+?{}|<>:!@#$%¨&*()"
      @allowed_chars =
        if allowed_chars
          allowed_chars
        else
          @chars
        end

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
            if shift; insert_char @chars[i + 57]
            else; insert_char @chars[i]; end
          elsif shift
            insert_char(@chars[i + 47])
          else
            insert_char(@chars[i - 10])
          end
          inserted = true
          break
        end
      end

      return if inserted
      for i in 55..64 # special
        if KB.key_pressed?(@k[i]) or KB.key_held?(@k[i])
          if shift; insert_char @chars[i + 18]
          else; insert_char @chars[i + 8]; end
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
        Game.window.draw_quad @nodes[@anchor1], @text_y, selection_color,
                              @nodes[@anchor2] + 1, @text_y, selection_color,
                              @nodes[@anchor2] + 1, @text_y + @font.height, selection_color,
                              @nodes[@anchor1], @text_y + @font.height, selection_color, z_index
      end

      if @cursor_visible
        if @cursor_img
          @cursor_img.draw @nodes[@cur_node] - @cursor_img.width / 2, @text_y, z_index
        else
          cursor_color = alpha << 24
          Game.window.draw_quad @nodes[@cur_node], @text_y, cursor_color,
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
      @text[min...max] = ""
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
end
