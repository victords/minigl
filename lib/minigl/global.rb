require 'gosu'

# The main module of the library, used only as a namespace.
module MiniGL
  # This class represents a point or vector in a bidimensional space.
  class Vector
    # The x coordinate of the vector
    attr_accessor :x

    # The y coordinate of the vector
    attr_accessor :y

    # Creates a new bidimensional vector.
    #
    # Parameters:
    # [x] The x coordinate of the vector
    # [y] The y coordinate of the vector
    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end

    # Returns +true+ if both coordinates of this vector are equal to the
    # corresponding coordinates of +other_vector+, with +precision+ decimal
    # places of precision.
    def ==(other_vector, precision = 6)
      @x.round(precision) == other_vector.x.round(precision) and
          @y.round(precision) == other_vector.y.round(precision)
    end

    # Returns +true+ if at least one coordinate of this vector is different from
    # the corresponding coordinate of +other_vector+, with +precision+ decimal
    # places of precision.
    def !=(other_vector, precision = 6)
      @x.round(precision) != other_vector.x.round(precision) or
          @y.round(precision) != other_vector.y.round(precision)
    end

    # Sums this vector with +other_vector+, i.e., sums each coordinate of this
    # vector with the corresponding coordinate of +other_vector+.
    def +(other_vector)
      Vector.new @x + other_vector.x, @y + other_vector.y
    end

    # Subtracts +other_vector+ from this vector, i.e., subtracts from each
    # coordinate of this vector the corresponding coordinate of +other_vector+.
    def -(other_vector)
      Vector.new @x - other_vector.x, @y - other_vector.y
    end

    # Multiplies this vector by a scalar, i.e., each coordinate is multiplied by
    # the given number.
    def *(scalar)
      Vector.new @x * scalar, @y * scalar
    end

    # Divides this vector by a scalar, i.e., each coordinate is divided by the
    # given number.
    def /(scalar)
      Vector.new @x / scalar.to_f, @y / scalar.to_f
    end

    # Returns the euclidean distance between this vector and +other_vector+.
    def distance(other_vector)
      dx = @x - other_vector.x
      dy = @y - other_vector.y
      Math.sqrt(dx ** 2 + dy ** 2)
    end

    # Returns a vector corresponding to the rotation of this vector around the
    # origin (0, 0) by +radians+ radians.
    def rotate(radians)
      sin = Math.sin radians
      cos = Math.cos radians
      Vector.new cos * @x - sin * @y, sin * @x + cos * @y
    end

    # Rotates this vector by +radians+ radians around the origin (0, 0).
    def rotate!(radians)
      sin = Math.sin radians
      cos = Math.cos radians
      prev_x = @x
      @x = cos * @x - sin * @y
      @y = sin * prev_x + cos * @y
    end
  end

  # This class represents a rectangle by its x and y coordinates and width and
  # height.
  class Rectangle
    # The x-coordinate of the rectangle.
    attr_accessor :x

    # The y-coordinate of the rectangle.
    attr_accessor :y

    # The width of the rectangle.
    attr_accessor :w

    # The height of the rectangle.
    attr_accessor :h

    # Creates a new rectangle.
    #
    # Parameters:
    # [x] The x-coordinate of the rectangle.
    # [y] The y-coordinate of the rectangle.
    # [w] The width of the rectangle.
    # [h] The height of the rectangle.
    def initialize(x, y, w, h)
      @x = x; @y = y; @w = w; @h = h
    end

    # Returns whether this rectangle intersects another.
    #
    # Parameters:
    # [r] The rectangle to check intersection with.
    def intersect?(r)
      @x < r.x + r.w && @x + @w > r.x && @y < r.y + r.h && @y + @h > r.y
    end
  end

  # This module contains references to global objects/constants used by MiniGL.
  module G
    class << self
      # A reference to the game window.
      attr_accessor :window

      # Gets or sets the value of gravity. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :gravity

      # Gets or sets the value of min_speed. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :min_speed

      # Gets or sets the value of ramp_contact_threshold. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :ramp_contact_threshold

      # Gets or sets the value of ramp_slip_threshold. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :ramp_slip_threshold

      # Gets or sets the value of kb_held_delay. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :kb_held_delay

      # Gets or sets the value of kb_held_interval. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :kb_held_interval

      # Gets or sets the value of double_click_delay. See
      # <code>GameWindow#initialize</code> for details.
      attr_accessor :double_click_delay
    end
  end

  # The main class for a MiniGL game, holds references to globally accessible
  # objects and constants.
  class GameWindow < Gosu::Window
    # Creates a game window (initializing a game with all MiniGL features
    # enabled).
    #
    # Parameters:
    # [scr_w] Width of the window, in pixels.
    # [scr_h] Height of the window, in pixels.
    # [fullscreen] Whether the window must be initialized in full screen mode.
    # [gravity] A Vector object representing the horizontal and vertical
    #           components of the force of gravity. Essentially, this force
    #           will be applied to every object which calls +move+, from the
    #           Movement module.
    # [min_speed] A Vector with the minimum speed for moving objects, i.e., the
    #             value below which the speed will be rounded to zero.
    # [ramp_contact_threshold] The maximum horizontal movement an object can
    #                          perform in a single frame and keep contact with a
    #                          ramp when it's above one.
    # [ramp_slip_threshold] The maximum ratio between height and width of a ramp
    #                       above which the objects will always slip down when
    #                       trying to 'climb' that ramp.
    # [kb_held_delay] The number of frames a key must be held by the user
    #                 before the "held" event (that can be checked with
    #                 <code>KB.key_held?</code>) starts to trigger.
    # [kb_held_interval] The interval, in frames, between each triggering of
    #                    the "held" event, after the key has been held for
    #                    more than +kb_held_delay+ frames.
    # [double_click_delay] The maximum interval, in frames, between two
    #                      clicks, to trigger the "double click" event
    #                      (checked with <code>Mouse.double_click?</code>).
    def initialize(scr_w, scr_h, fullscreen = true,
                   gravity = Vector.new(0, 1), min_speed = Vector.new(0.01, 0.01),
                   ramp_contact_threshold = 10, ramp_slip_threshold = 1.2,
                   kb_held_delay = 40, kb_held_interval = 5, double_click_delay = 8)
      super scr_w, scr_h, fullscreen
      G.window = self
      G.gravity = gravity
      G.min_speed = min_speed
      G.ramp_contact_threshold = ramp_contact_threshold
      G.ramp_slip_threshold = ramp_slip_threshold
      G.kb_held_delay = kb_held_delay
      G.kb_held_interval = kb_held_interval
      G.double_click_delay = double_click_delay
      KB.initialize
      Mouse.initialize
      Res.initialize
    end

    # Draws a rectangle with the size of the entire screen, in the given color.
    #
    # Parameters:
    # [color] Color of the rectangle to be drawn.
    def clear(color)
      draw_quad 0, 0, color,
                width, 0, color,
                width, height, color,
                0, height, color, 0
    end

    # def toggle_fullscreen
    #   # TODO
    # end
  end

  #class JSHelper

  # Exposes methods for controlling keyboard events.
  module KB
    class << self
      # This is called by <code>GameWindow.initialize</code>. Don't call it
      # explicitly.
      def initialize
        @keys = [
          Gosu::KbUp, Gosu::KbDown,
          Gosu::KbReturn, Gosu::KbEscape,
          Gosu::KbLeftControl, Gosu::KbRightControl,
          Gosu::KbLeftAlt, Gosu::KbRightAlt,
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
          Gosu::KbEnd, Gosu::KbLeftShift, Gosu::KbRightShift, Gosu::KbTab,
          Gosu::KbBacktick, Gosu::KbMinus, Gosu::KbEqual, Gosu::KbBracketLeft,
          Gosu::KbBracketRight, Gosu::KbBackslash, Gosu::KbApostrophe,
          Gosu::KbComma, Gosu::KbPeriod, Gosu::KbSlash
        ]
        @down = []
        @prev_down = []
        @held_timer = {}
        @held_interval = {}
      end

      # Updates the state of all keys.
      def update
        @held_timer.each do |k, v|
          if v < G.kb_held_delay; @held_timer[k] += 1
          else
            @held_interval[k] = 0
            @held_timer.delete k
          end
        end

        @held_interval.each do |k, v|
          if v < G.kb_held_interval; @held_interval[k] += 1
          else; @held_interval[k] = 0; end
        end

        @prev_down = @down.clone
        @down.clear
        @keys.each do |k|
          if G.window.button_down? k
            @down << k
            @held_timer[k] = 0 if @prev_down.index(k).nil?
          elsif @prev_down.index(k)
            @held_timer.delete k
            @held_interval.delete k
          end
        end
      end

      # Returns whether the given key is down in the current frame and was not
      # down in the frame before.
      #
      # Parameters:
      # [key] Code of the key to be checked. The available codes are <code>
      #       Gosu::KbUp, Gosu::KbDown, Gosu::KbReturn, Gosu::KbEscape,
      #       Gosu::KbLeftControl, Gosu::KbRightControl,
      #       Gosu::KbLeftAlt, Gosu::KbRightAlt,
      #       Gosu::KbA, Gosu::KbB, Gosu::KbC, Gosu::KbD, Gosu::KbE, Gosu::KbF,
      #       Gosu::KbG, Gosu::KbH, Gosu::KbI, Gosu::KbJ, Gosu::KbK, Gosu::KbL,
      #       Gosu::KbM, Gosu::KbN, Gosu::KbO, Gosu::KbP, Gosu::KbQ, Gosu::KbR,
      #       Gosu::KbS, Gosu::KbT, Gosu::KbU, Gosu::KbV, Gosu::KbW, Gosu::KbX,
      #       Gosu::KbY, Gosu::KbZ, Gosu::Kb1, Gosu::Kb2, Gosu::Kb3, Gosu::Kb4,
      #       Gosu::Kb5, Gosu::Kb6, Gosu::Kb7, Gosu::Kb8, Gosu::Kb9, Gosu::Kb0,
      #       Gosu::KbNumpad1, Gosu::KbNumpad2, Gosu::KbNumpad3, Gosu::KbNumpad4,
      #       Gosu::KbNumpad5, Gosu::KbNumpad6, Gosu::KbNumpad7, Gosu::KbNumpad8,
      #       Gosu::KbNumpad9, Gosu::KbNumpad0, Gosu::KbSpace, Gosu::KbBackspace,
      #       Gosu::KbDelete, Gosu::KbLeft, Gosu::KbRight, Gosu::KbHome,
      #       Gosu::KbEnd, Gosu::KbLeftShift, Gosu::KbRightShift, Gosu::KbTab,
      #       Gosu::KbBacktick, Gosu::KbMinus, Gosu::KbEqual, Gosu::KbBracketLeft,
      #       Gosu::KbBracketRight, Gosu::KbBackslash, Gosu::KbApostrophe,
      #       Gosu::KbComma, Gosu::KbPeriod, Gosu::KbSlash</code>.
      def key_pressed?(key)
        @prev_down.index(key).nil? and @down.index(key)
      end

      # Returns whether the given key is down in the current frame.
      #
      # Parameters:
      # [key] Code of the key to be checked. See +key_pressed?+ for details.
      def key_down?(key)
        @down.index(key)
      end

      # Returns whether the given key is not down in the current frame but was
      # down in the frame before.
      #
      # Parameters:
      # [key] Code of the key to be checked. See +key_pressed?+ for details.
      def key_released?(key)
        @prev_down.index(key) and @down.index(key).nil?
      end

      # Returns whether the given key is being held down. See
      # <code>GameWindow.initialize</code> for details.
      #
      # Parameters:
      # [key] Code of the key to be checked. See +key_pressed?+ for details.
      def key_held?(key)
        @held_interval[key] == G.kb_held_interval
      end
    end
  end

  # Exposes methods for controlling mouse events.
  module Mouse
    class << self
      # The current x-coordinate of the mouse cursor in the screen.
      attr_reader :x

      # The current y-coordinate of the mouse cursor in the screen.
      attr_reader :y

      # This is called by <code>GameWindow.initialize</code>. Don't call it
      # explicitly.
      def initialize
        @down = {}
        @prev_down = {}
        @dbl_click = {}
        @dbl_click_timer = {}
      end

      # Updates the mouse position and the state of all buttons.
      def update
        @prev_down = @down.clone
        @down.clear
        @dbl_click.clear

        @dbl_click_timer.each do |k, v|
          if v < G.double_click_delay; @dbl_click_timer[k] += 1
          else; @dbl_click_timer.delete k; end
        end

        k1 = [Gosu::MsLeft, Gosu::MsMiddle, Gosu::MsRight]
        k2 = [:left, :middle, :right]
        for i in 0..2
          if G.window.button_down? k1[i]
            @down[k2[i]] = true
            @dbl_click[k2[i]] = true if @dbl_click_timer[k2[i]]
            @dbl_click_timer.delete k2[i]
          elsif @prev_down[k2[i]]
            @dbl_click_timer[k2[i]] = 0
          end
        end

        @x = G.window.mouse_x.round
        @y = G.window.mouse_y.round
      end

      # Returns whether the given button is down in the current frame and was
      # not down in the frame before.
      #
      # Parameters:
      # [btn] Button to be checked. Valid values are +:left+, +:middle+ and
      #       +:right+
      def button_pressed?(btn)
        @down[btn] and not @prev_down[btn]
      end

      # Returns whether the given button is down in the current frame.
      #
      # Parameters:
      # [btn] Button to be checked. Valid values are +:left+, +:middle+ and
      #       +:right+
      def button_down?(btn)
        @down[btn]
      end

      # Returns whether the given button is not down in the current frame, but
      # was down in the frame before.
      #
      # Parameters:
      # [btn] Button to be checked. Valid values are +:left+, +:middle+ and
      #       +:right+
      def button_released?(btn)
        @prev_down[btn] and not @down[btn]
      end

      # Returns whether the given button has just been double clicked.
      #
      # Parameters:
      # [btn] Button to be checked. Valid values are +:left+, +:middle+ and
      #       +:right+
      def double_click?(btn)
        @dbl_click[btn]
      end

      # Returns whether the mouse cursor is currently inside the given area.
      #
      # Parameters:
      # [x] The x-coordinate of the top left corner of the area.
      # [y] The y-coordinate of the top left corner of the area.
      # [w] The width of the area.
      # [h] The height of the area.
      def over?(x, y, w, h)
        @x >= x and @x < x + w and @y >= y and @y < y + h
      end
    end
  end

  # This class is responsible for resource management. It keeps references to
  # all loaded resources until a call to +clear+ is made. Resources can be
  # loaded as global, so that their references won't be removed even when
  # +clear+ is called.
  #
  # It also provides an easier syntax for loading resources, assuming a
  # particular folder structure. All resources must be inside subdirectories
  # of a 'data' directory, so that you will only need to specify the type of
  # resource being loaded and the file name (either as string or as symbol).
  # There are default extensions for each type of resource, so the extension
  # must be specified only if the file is in a format other than the default.
  module Res
    class << self
      # Get the current prefix for searching data files. This is the directory
      # under which 'img', 'sound', 'song', etc. folders are located.
      attr_reader :prefix

      # Gets the current path to image files (under +prefix+). Default is 'img'.
      attr_reader :img_dir

      # Gets the current path to tileset files (under +prefix+). Default is
      # 'tileset'.
      attr_reader :tileset_dir

      # Gets the current path to sound files (under +prefix+). Default is 'sound'.
      attr_reader :sound_dir

      # Gets the current path to song files (under +prefix+). Default is 'song'.
      attr_reader :song_dir

      # Gets the current path to font files (under +prefix+). Default is 'font'.
      attr_reader :font_dir

      # Gets or sets the character that is currently being used in the +id+
      # parameter of the loading methods as a folder separator. Default is '_'.
      # Note that if you want to use symbols to specify paths, this separator
      # should be a valid character in a Ruby symbol. On the other hand, if you
      # want to use only slashes in Strings, you can specify a 'weird' character
      # that won't appear in any file name.
      attr_accessor :separator

      # This is called by <code>GameWindow.initialize</code>. Don't call it
      # explicitly.
      def initialize
        @imgs = {}
        @global_imgs = {}
        @tilesets = {}
        @global_tilesets = {}
        @sounds = {}
        @global_sounds = {}
        @songs = {}
        @global_songs = {}
        @fonts = {}
        @global_fonts = {}

        @prefix = File.expand_path(File.dirname($0)) + '/data/'
        @img_dir = 'img/'
        @tileset_dir = 'tileset/'
        @sound_dir = 'sound/'
        @song_dir = 'song/'
        @font_dir = 'font/'
        @separator = '_'
      end

      # Set a custom prefix for loading resources. By default, the prefix is the
      # directory of the game script. The prefix is the directory under which
      # 'img', 'sound', 'song', etc. folders are located.
      def prefix=(value)
        value += '/' if value[-1] != '/'
        @prefix = value
      end

      # Sets the path to image files (under +prefix+). Default is 'img'.
      def img_dir=(value)
        value += '/' if value[-1] != '/'
        @img_dir = value
      end

      # Sets the path to tilset files (under +prefix+). Default is 'tileset'.
      def tileset_dir=(value)
        value += '/' if value[-1] != '/'
        @tileset_dir = value
      end

      # Sets the path to sound files (under +prefix+). Default is 'sound'.
      def sound_dir=(value)
        value += '/' if value[-1] != '/'
        @sound_dir = value
      end

      # Sets the path to song files (under +prefix+). Default is 'song'.
      def song_dir=(value)
        value += '/' if value[-1] != '/'
        @song_dir = value
      end

      # Sets the path to font files (under +prefix+). Default is 'font'.
      def font_dir=(value)
        value += '/' if value[-1] != '/'
        @font_dir = value
      end

      # Returns a <code>Gosu::Image</code> object.
      #
      # Parameters:
      # [id] A string or symbol representing the path to the image. If the file
      #      is inside +prefix+/+img_dir+, only the file name is needed. If it's
      #      inside a subdirectory of +prefix+/+img_dir+, the id must be
      #      prefixed by each subdirectory name followed by +separator+. Example:
      #      to load 'data/img/sprite/1.png', with the default values of +prefix+,
      #      +img_dir+ and +separator+, provide +:sprite_1+ or "sprite_1".
      # [global] Set to true if you want to keep the image in memory until the
      #          game execution is finished. If false, the image will be
      #          released when you call +clear+.
      # [tileable] Whether the image should be loaded in tileable mode, which is
      #            proper for images that will be used as a tile, i.e., that
      #            will be drawn repeated times, side by side, forming a
      #            continuous composition.
      # [ext] The extension of the file being loaded. Specify only if it is
      #       other than '.png'.
      def img(id, global = false, tileable = false, ext = '.png')
        if global; a = @global_imgs; else; a = @imgs; end
        return a[id] if a[id]
        s = @prefix + @img_dir + id.to_s.split(@separator).join('/') + ext
        img = Gosu::Image.new G.window, s, tileable
        a[id] = img
      end

      # Returns an array of <code>Gosu::Image</code> objects, using the image as
      # a spritesheet. The image with index 0 will be the top left sprite, and
      # the following indices raise first from left to right and then from top
      # to bottom.
      #
      # Parameters:
      # [id] A string or symbol representing the path to the image. See +img+
      #      for details.
      # [sprite_cols] Number of columns in the spritesheet.
      # [sprite_rows] Number of rows in the spritesheet.
      # [global] Set to true if you want to keep the image in memory until the
      #          game execution is finished. If false, the image will be
      #          released when you call +clear+.
      # [ext] The extension of the file being loaded. Specify only if it is
      #       other than ".png".
      def imgs(id, sprite_cols, sprite_rows, global = false, ext = '.png')
        if global; a = @global_imgs; else; a = @imgs; end
        return a[id] if a[id]
        s = @prefix + @img_dir + id.to_s.split(@separator).join('/') + ext
        imgs = Gosu::Image.load_tiles G.window, s, -sprite_cols, -sprite_rows, false
        a[id] = imgs
      end

      # Returns an array of <code>Gosu::Image</code> objects, using the image as
      # a tileset. Works the same as +imgs+, except you must provide the tile
      # size instead of the number of columns and rows, and that the images will
      # be loaded as tileable.
      #
      # Parameters:
      # [id] A string or symbol representing the path to the image. It must be
      #      specified the same way as in +img+, but the base directory is
      #      +prefix+/+tileset_dir+.
      # [tile_width] Width of each tile, in pixels.
      # [tile_height] Height of each tile, in pixels.
      # [global] Set to true if you want to keep the image in memory until the
      #          game execution is finished. If false, the image will be
      #          released when you call +clear+.
      # [ext] The extension of the file being loaded. Specify only if it is
      #       other than ".png".
      def tileset(id, tile_width = 32, tile_height = 32, global = false, ext = '.png')
        if global; a = @global_tilesets; else; a = @tilesets; end
        return a[id] if a[id]
        s = @prefix + @tileset_dir + id.to_s.split(@separator).join('/') + ext
        tileset = Gosu::Image.load_tiles G.window, s, tile_width, tile_height, true
        a[id] = tileset
      end

      # Returns a <code>Gosu::Sample</code> object. This should be used for
      # simple and short sound effects.
      #
      # Parameters:
      # [id] A string or symbol representing the path to the sound. It must be
      #      specified the same way as in +img+, but the base directory is
      #      +prefix+/+sound_dir+.
      # [global] Set to true if you want to keep the sound in memory until the
      #          game execution is finished. If false, the sound will be
      #          released when you call +clear+.
      # [ext] The extension of the file being loaded. Specify only if it is
      #       other than ".wav".
      def sound(id, global = false, ext = '.wav')
        if global; a = @global_sounds; else; a = @sounds; end
        return a[id] if a[id]
        s = @prefix + @sound_dir + id.to_s.split(@separator).join('/') + ext
        sound = Gosu::Sample.new G.window, s
        a[id] = sound
      end

      # Returns a <code>Gosu::Song</code> object. This should be used for the
      # background musics of your game.
      #
      # Parameters:
      # [id] A string or symbol representing the path to the song. It must be
      #      specified the same way as in +img+, but the base directory is
      #      +prefix+/+song_dir+.
      # [global] Set to true if you want to keep the song in memory until the
      #          game execution is finished. If false, the song will be released
      #          when you call +clear+.
      # [ext] The extension of the file being loaded. Specify only if it is
      #       other than ".ogg".
      def song(id, global = false, ext = '.ogg')
        if global; a = @global_songs; else; a = @songs; end
        return a[id] if a[id]
        s = @prefix + @song_dir + id.to_s.split(@separator).join('/') + ext
        song = Gosu::Song.new G.window, s
        a[id] = song
      end

      # Returns a <code>Gosu::Font</code> object. Fonts are needed to draw text
      # and used by MiniGL elements like buttons, text fields and TextHelper
      # objects.
      #
      # Parameters:
      # [id] A string or symbol representing the path to the song. It must be
      #      specified the same way as in +img+, but the base directory is
      #      +prefix+/+font_dir+.
      # [size] The size of the font, in pixels. This will correspond,
      #        approximately, to the height of the tallest character when drawn.
      # [global] Set to true if you want to keep the font in memory until the
      #          game execution is finished. If false, the font will be released
      #          when you call +clear+.
      # [ext] The extension of the file being loaded. Specify only if it is
      #       other than ".ttf".
      def font(id, size, global = true, ext = '.ttf')
        if global; a = @global_fonts; else; a = @fonts; end
        id_size = "#{id}_#{size}"
        return a[id_size] if a[id_size]
        s = @prefix + @font_dir + id.to_s.split(@separator).join('/') + ext
        font = Gosu::Font.new G.window, s, size
        a[id_size] = font
      end

      # Releases the memory used by all non-global resources.
      def clear
        @imgs.clear
        @tilesets.clear
        @sounds.clear
        @songs.clear
        @fonts.clear
      end
    end
  end
end
