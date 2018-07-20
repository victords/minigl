require_relative 'movement'

module MiniGL
  # This class represents an (optionally animated) image inside the game screen.
  class Sprite
    # The index of the current sprite in the spritesheet being drawn.
    attr_reader :img_index

    # The x-coordinate of the image in the screen.
    attr_accessor :x

    # The y-coordinate of the image in the screen.
    attr_accessor :y

    # Creates a new sprite.
    #
    # Parameters:
    # [x] The x-coordinate in the screen (or map) where the sprite will be
    #     drawn. This can be modified later via the +x+ attribute.
    # [y] The y-coordinate in the screen (or map) where the sprite will be
    #     drawn. This can be modified later via the +y+ attribute.
    # [img] The path to a PNG image or spritesheet, following the MiniGL
    #       convention: images must be inside a 'data/img' directory, relative
    #       to the code file, and you must only provide the file name, without
    #       extension, in this case. If the image is inside a subdirectory of
    #       'data/img', you must prefix the file name with each subdirectory
    #       name, followed by an underscore (so the file and directories names
    #       must not contain underscores). For example, if your image is
    #       'data/img/sprite/1.png', you must provide <code>"sprite_1"</code>
    #       or +:sprite_1+.
    # [sprite_cols] The number of columns in the spritesheet. Use +nil+ if the
    #               image is not a spritesheet.
    # [sprite_rows] The number of rows in the spritesheet. Use +nil+ if the
    #               image is not a spritesheet.
    def initialize(x, y, img, sprite_cols = nil, sprite_rows = nil)
      @x = x; @y = y
      @img =
        if sprite_cols.nil?
          [Res.img(img)]
        else
          Res.imgs img, sprite_cols, sprite_rows
        end
      @anim_counter = 0
      @img_index = 0
      @index_index = 0
      @animate_once_control = 0
    end

    # Performs time checking to update the image index according to the
    # sequence of indices and the interval.
    #
    # Parameters:
    # [indices] The sequence of image indices used in the animation. The
    #           indices are determined from left to right, and from top to
    #           bottom, inside the spritesheet. All indices must be in the
    #           interval <code>0..(sprite_cols * sprite_rows)</code>.
    # [interval] The amount of frames between each change in the image index.
    #            A frame will usually represent 1/60 second (roughly 17
    #            milliseconds).
    def animate(indices, interval)
      @animate_once_control = 0 if @animate_once_control != 0

      @anim_counter += 1
      if @anim_counter >= interval
        @index_index += 1
        @index_index = 0 if @index_index >= indices.length
        @img_index = indices[@index_index]
        @anim_counter = 0
      end
    end

    # Causes the sprite to animate through the +indices+ array exactly once,
    # so that the animation stops once it reaches the last index in the array.
    # Subsequent calls with the same parameters will have no effect, but if
    # the index or interval changes, or if +set_animation+ is called, then a
    # new animation cycle will begin.
    #
    # Parameters:
    # [indices] The sequence of image indices used in the animation. See
    #           +animate+ for details.
    # [interval] The amount of frames between each change in the image index.
    #            See +animate+ for details.
    def animate_once(indices, interval)
      if @animate_once_control == 2
        return if indices == @animate_once_indices && interval == @animate_once_interval
        @animate_once_control = 0
      end

      unless @animate_once_control == 1
        @anim_counter = 0
        @img_index = indices[0]
        @index_index = 0
        @animate_once_indices = indices
        @animate_once_interval = interval
        @animate_once_control = 1
        return
      end

      @anim_counter += 1
      return unless @anim_counter >= interval

      @index_index += 1
      @img_index = indices[@index_index]
      @anim_counter = 0
      @animate_once_control = 2 if @index_index == indices.length - 1
    end

    # Resets the animation timer and immediately changes the image index to
    # the specified value.
    #
    # Parameters:
    # [index] The image index to be set.
    def set_animation(index)
      @anim_counter = 0
      @img_index = index
      @index_index = 0
      @animate_once_control = 0
    end

    # Draws the sprite in the screen
    #
    # Parameters:
    # [map] A Map object, relative to which the sprite will be drawn (the x
    #       and y coordinates of the sprite will be changed according to the
    #       position of the camera).
    # [scale_x] A scale factor to be applied horizontally to the image.
    # [scale_y] A scale factor to be applied vertically to the image.
    # [alpha] The opacity with which the image will be drawn. Valid values
    #         vary from 0 (fully transparent) to 255 (fully opaque).
    # [color] A color filter to apply to the image. A white (0xffffff) filter
    #         will keep all colors unchanged, while a black (0x000000) filter
    #         will turn all colors to black. A red (0xff0000) filter will keep
    #         reddish colors with slight or no change, whereas bluish colors
    #         will be darkened, for example.
    # [angle] A rotation, in degrees, to be applied to the image, relative to
    #         its center.
    # [flip] Specify +:horiz+ to draw the image horizontally flipped or +:vert+
    #        to draw it vertically flipped.
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    # [round] Specify whether the drawing coordinates should be rounded to an
    #         integer before drawing, to avoid little distortions of the image.
    #         Only applies when the image is not rotated.
    #
    # *Obs.:* This method accepts named parameters.
    def draw(map = nil, scale_x = 1, scale_y = 1, alpha = 0xff, color = 0xffffff, angle = nil, flip = nil, z_index = 0, round = false)
      if map.is_a? Hash
        scale_x = map.fetch(:scale_x, 1)
        scale_y = map.fetch(:scale_y, 1)
        alpha = map.fetch(:alpha, 0xff)
        color = map.fetch(:color, 0xffffff)
        angle = map.fetch(:angle, nil)
        flip = map.fetch(:flip, nil)
        z_index = map.fetch(:z_index, 0)
        round = map.fetch(:round, false)
        map = map.fetch(:map, nil)
      end

      color = (alpha << 24) | color
      if angle
        @img[@img_index].draw_rot @x - (map ? map.cam.x : 0) + @img[0].width * scale_x * 0.5,
                                  @y - (map ? map.cam.y : 0) + @img[0].height * scale_y * 0.5,
                                  z_index, angle, 0.5, 0.5, (flip == :horiz ? -scale_x : scale_x),
                                  (flip == :vert ? -scale_y : scale_y), color
      else
        x = @x - (map ? map.cam.x : 0) + (flip == :horiz ? scale_x * @img[0].width : 0)
        y = @y - (map ? map.cam.y : 0) + (flip == :vert ? scale_y * @img[0].height : 0)
        @img[@img_index].draw (round ? x.round : x), (round ? y.round : y),
                              z_index, (flip == :horiz ? -scale_x : scale_x),
                              (flip == :vert ? -scale_y : scale_y), color
      end
    end

    # Returns whether this sprite is visible in the given map (i.e., in the
    # viewport determined by the camera of the given map). If no map is given,
    # returns whether the sprite is visible on the screen.
    def visible?(map = nil)
      r = Rectangle.new @x, @y, @img[0].width, @img[0].height
      return Rectangle.new(0, 0, G.window.width, G.window.height).intersect? r if map.nil?
      map.cam.intersect? r
    end
  end

  # This class represents an object with a set of properties and methods
  # commonly used in games. It defines an object with a rectangular bounding
  # box, and having all the attributes required for using the Movement module.
  class GameObject < Sprite
    include Movement

    # Creates a new game object.
    #
    # Parameters:
    # [x] The x-coordinate of the object's bounding box. This can be modified
    #     later via the +x+ attribute.
    # [y] The y-coordinate of the object's bounding box. This can be modified
    #     later via the +y+ attribute.
    # [w] The width of the object's bounding box.
    # [h] The height of the object's bounding box.
    # [img] The image or spritesheet for the object.
    # [img_gap] A Vector object representing the difference between the top
    #           left corner of the bounding box and the coordinates of the
    #           image. For example, an object with <code>x = 100</code>,
    #           <code>y = 50</code> and <code>img_gap = Vector.new(-5, -5)</code>
    #           will be drawn at position (95, 45) of the screen.
    # [sprite_cols] The number of columns in the spritesheet. Use +nil+ if the
    #               image is not a spritesheet.
    # [sprite_rows] The number of rows in the spritesheet. Use +nil+ if the
    #               image is not a spritesheet.
    # [mass] The mass of the object. Details on how it is used can be found
    #        in the Movement module.
    def initialize(x, y, w, h, img, img_gap = nil, sprite_cols = nil, sprite_rows = nil, mass = 1.0)
      super x, y, img, sprite_cols, sprite_rows
      @w = w; @h = h
      @img_gap =
        if img_gap.nil?
          Vector.new 0, 0
        else
          img_gap
        end
      @mass = mass
      @speed = Vector.new 0, 0
      @max_speed = Vector.new 15, 15
      @stored_forces = Vector.new 0, 0
    end

    # Draws the game object in the screen.
    #
    # Parameters:
    # [map] A Map object, relative to which the object will be drawn (the x
    #       and y coordinates of the image will be changed according to the
    #       position of the camera).
    # [scale_x] A scale factor to be applied horizontally to the image.
    # [scale_y] A scale factor to be applied vertically to the image.
    # [alpha] The opacity with which the image will be drawn. Valid values
    #         vary from 0 (fully transparent) to 255 (fully opaque).
    # [color] A color filter to apply to the image. A white (0xffffff) filter
    #         will keep all colors unchanged, while a black (0x000000) filter
    #         will turn all colors to black. A red (0xff0000) filter will keep
    #         reddish colors with slight or no change, whereas bluish colors
    #         will be darkened, for example.
    # [angle] A rotation, in degrees, to be applied to the image, relative to
    #         its center.
    # [flip] Specify +:horiz+ to draw the image horizontally flipped or +:vert+
    #        to draw it vertically flipped.
    # [z_index] The z-order to draw the object. Objects with larger z-orders
    #           will be drawn on top of the ones with smaller z-orders.
    # [round] Specify whether the drawing coordinates should be rounded to an
    #         integer before drawing, to avoid little distortions of the image.
    #         Only applies when the image is not rotated.
    #
    # *Obs.:* This method accepts named parameters.
    def draw(map = nil, scale_x = 1, scale_y = 1, alpha = 0xff, color = 0xffffff, angle = nil, flip = nil, z_index = 0, round = false)
      if map.is_a? Hash
        scale_x = map.fetch(:scale_x, 1)
        scale_y = map.fetch(:scale_y, 1)
        alpha = map.fetch(:alpha, 0xff)
        color = map.fetch(:color, 0xffffff)
        angle = map.fetch(:angle, nil)
        flip = map.fetch(:flip, nil)
        z_index = map.fetch(:z_index, 0)
        round = map.fetch(:round, false)
        map = map.fetch(:map, nil)
      end

      color = (alpha << 24) | color
      if angle
        center_x = @x + @w * 0.5
        center_y = @y + @h * 0.5
        o_x = center_x - @x - @img_gap.x
        o_y = center_y - @y - @img_gap.y
        @img[@img_index].draw_rot @x + (flip == :horiz ? -1 : 1) * (@img_gap.x + o_x) - (map ? map.cam.x : 0),
                                  @y + (flip == :vert ? -1 : 1) * (@img_gap.y + o_y) - (map ? map.cam.y : 0),
                                  z_index, angle, o_x.to_f / @img[0].width, o_y.to_f / @img[0].height,
                                  (flip == :horiz ? -scale_x : scale_x), (flip == :vert ? -scale_y : scale_y), color
      else
        x = @x + (flip == :horiz ? -1 : 1) * @img_gap.x - (map ? map.cam.x : 0) + (flip == :horiz ? @w : 0)
        y = @y + (flip == :vert ? -1 : 1) * @img_gap.y - (map ? map.cam.y : 0) + (flip == :vert ? @h : 0)
        @img[@img_index].draw (round ? x.round : x), (round ? y.round : y),
                              z_index, (flip == :horiz ? -scale_x : scale_x),
                              (flip == :vert ? -scale_y : scale_y), color
      end
    end

    # Returns whether this object is visible in the given map (i.e., in the
    # viewport determined by the camera of the given map). If no map is given,
    # returns whether the object is visible on the screen.
    def visible?(map = nil)
      r = Rectangle.new @x.round + @img_gap.x, @y.round + @img_gap.y, @img[0].width, @img[0].height
      return Rectangle.new(0, 0, G.window.width, G.window.height).intersect? r if map.nil?
      map.cam.intersect? r
    end
  end

  # Represents a visual effect, i.e., a graphic - usually animated - that shows
  # up in the screen, lasts for a given time and "disappears". You should
  # explicitly dispose of references to effects whose attribute +dead+ is set
  # to +true+.
  class Effect < Sprite
    # This is +true+ when the effect's lifetime has already passed.
    attr_reader :dead

    # Creates a new Effect.
    #
    # Parameters:
    # [x] The x-coordinate in the screen (or map) where the effect will be
    #     drawn. This can be modified later via the +x+ attribute.
    # [y] The y-coordinate in the screen (or map) where the effect will be
    #     drawn. This can be modified later via the +y+ attribute.
    # [img] The image or spritesheet to use for this effect (see Sprite for
    #       details on spritesheets).
    # [sprite_cols] (see Sprite)
    # [sprite_rows] (see Sprite)
    # [interval] The interval between steps of the animation, in updates.
    # [indices] The indices to use in the animation. See Sprite#animate for
    #           details. If +nil+, it will be the sequence from 0 to
    #           <code>sprite_cols * sprite_rows - 1</code>.
    # [lifetime] The lifetime of the effect, in updates. After +update+ is
    #            called this number of times, the effect will no longer
    #            be visible, even when +draw+ is called, and the +dead+ flag
    #            will be set to +true+, so you get to know when to dispose
    #            of the Effect object. If +nil+, it will be set to
    #            <code>@indices.length * interval</code>, i.e., the exact time
    #            needed for one animation cycle to complete.
    # [sound] The id of a sound to be played when the effect is created (id must
    #         be given in the format specified for the +Res.sound+ method).
    # [sound_ext] Extension of the sound file, if a sound is given. Default is
    #             '.wav'.
    # [sound_volume] The volume (from 0 to 1) to play the sound, if any. Default
    #                is 1.
    #
    # *Obs.:* This method accepts named parameters, but +x+, +y+ and +img+ are
    # mandatory.
    def initialize(x, y = nil, img = nil, sprite_cols = nil, sprite_rows = nil, interval = 10, indices = nil, lifetime = nil,
                   sound = nil, sound_ext = '.wav', sound_volume = 1)
      if x.is_a? Hash
        y = x[:y]
        img = x[:img]
        sprite_cols = x.fetch(:sprite_cols, nil)
        sprite_rows = x.fetch(:sprite_rows, nil)
        interval = x.fetch(:interval, 10)
        indices = x.fetch(:indices, nil)
        lifetime = x.fetch(:lifetime, nil)
        sound = x.fetch(:sound, nil)
        sound_ext = x.fetch(:sound_ext, '.wav')
        sound_volume = x.fetch(:sound_volume, 1)
        x = x[:x]
      end

      super x, y, img, sprite_cols, sprite_rows
      @timer = 0
      if indices
        @indices = indices
      else
        @indices = *(0..(@img.length - 1))
      end
      @interval = interval
      if lifetime
        @lifetime = lifetime
      else
        @lifetime = @indices.length * interval
      end
      Res.sound(sound, false, sound_ext).play(sound_volume) if sound
    end

    # Updates the effect, animating and counting its remaining lifetime.
    def update
      unless @dead
        animate @indices, @interval
        @timer += 1
        @dead = true if @timer == @lifetime
      end
    end

    def draw(map = nil, scale_x = 1, scale_y = 1, alpha = 0xff, color = 0xffffff, angle = nil, z_index = 0)
      super unless @dead
    end
  end
end
