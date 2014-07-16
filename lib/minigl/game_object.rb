require_relative 'movement'

module AGL
	# This class represents an (optionally animated) image inside the game screen.
	class Sprite
		# The index of the current sprite in the spritesheet being drawn.
		attr_reader :img_index
		
		# The x-coordinate of the image in the screen.
		attr_accessor :x
		
		# The y-coordinate of the image in the screen.
		attr_accessor :y
		
		# Creates a new sprite.
		# Parameters:
		# [x] The x-coordinate where the sprite will be drawn in the screen.
		# [y] The y-coordinate where the sprite will be drawn in the screen.
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
		def initialize x, y, img, sprite_cols = nil, sprite_rows = nil
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
		end
		
		# Performs time checking to update the image index according to the
		# sequence of indices and the interval.
		# Parameters:
		# [indices] The sequence of image indices used in the animation. The
		#           indices are determined from left to right, and from top to
		#           bottom, inside the spritesheet. All indices must be in the
		#           interval <code>0..(sprite_cols * sprite_rows)</code>.
		# [interval] The amount of frames between each change in the image index.
		#            A frame will usually represent 1/60 second (roughly 17
		#            milliseconds).
		def animate indices, interval
			@anim_counter += 1
			if @anim_counter >= interval
				@index_index += 1
				@index_index = 0 if @index_index == indices.length
				@img_index = indices[@index_index]
				@anim_counter = 0
			end
		end
		
		def draw map = nil, scale_x = 1, scale_y = 1, alpha = 0xff, color = 0xffffff, angle = nil
			color = (alpha << 24) | color
			if map
				if angle
					@img[@img_index].draw_rot @x.round - map.cam.x, @y.round - map.cam.y, 0, angle, 0.5, 0.5, scale_x, scale_y, color
				else
					@img[@img_index].draw @x.round - map.cam.x, @y.round - map.cam.y, 0, scale_x, scale_y, color
				end
			elsif angle
				@img[@img_index].draw_rot @x.round, @y.round, 0, angle, 0.5, 0.5, scale_x, scale_y, color
			else
				@img[@img_index].draw @x.round, @y.round, 0, scale_x, scale_y, color
			end
		end
	end

	class GameObject < Sprite
		include Movement
		
		def initialize x, y, w, h, img, img_gap = nil, sprite_cols = nil, sprite_rows = nil
			super x, y, img, sprite_cols, sprite_rows
			@w = w; @h = h
			@img_gap =
				if img_gap.nil?
					Vector.new 0, 0
				else
					img_gap
				end
			@speed = Vector.new 0, 0
			@min_speed = Vector.new 0.01, 0.01
			@max_speed = Vector.new 15, 15
			@stored_forces = Vector.new 0, 0
		end
		
		def set_animation index
			@anim_counter = 0
			@img_index = index
			@index_index = 0
		end
		
		def is_visible map
			return map.cam.intersects @active_bounds if @active_bounds
			false
		end
		
		def draw map = nil, scale_x = 1, scale_y = 1, alpha = 0xff, color = 0xffffff, angle = nil
			color = (alpha << 24) | color
			if map
				if angle
					@img[@img_index].draw_rot @x.round + @img_gap.x - map.cam.x,
					                          @y.round + @img_gap.y - map.cam.y,
					                          0, angle, 0.5, 0.5, scale_x, scale_y, color
				else
					@img[@img_index].draw @x.round + @img_gap.x - map.cam.x, @y.round + @img_gap.y - map.cam.y, 0, scale_x, scale_y, color
				end
			elsif angle
				@img[@img_index].draw_rot @x.round + @img_gap.x, @y.round + @img_gap.y, 0, angle, 0.5, 0.5, scale_x, scale_y, color
			else
				@img[@img_index].draw @x.round + @img_gap.x, @y.round + @img_gap.y, 0, scale_x, scale_y, color
			end
		end
	end
	
	class Effect < Sprite
		def initialize x, y, life_time, img, sprite_cols = nil, sprite_rows = nil, indices = nil, interval = 1
			super x, y, img, sprite_cols, sprite_rows
			@life_time = life_time
			@timer = 0
			if indices
				@indices = indices
			else
				@indices = *(0..(@img.length - 1))
			end
			@interval = interval
		end
		
		def update
			animate @indices, @interval
			@timer += 1
			if @timer == @life_time
				@dead = true
			end
		end
	end
end
