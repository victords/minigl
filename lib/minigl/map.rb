require_relative 'global'

module AGL
	# This class provides easy control of a tile map, i.e., a map consisting of
	# a grid of equally sized tiles. It also provides viewport control, through
	# its camera property and methods.
	class Map
    # :nodoc:
    Sqrt2Div2 = Math.sqrt(2) / 2
    # :nodoc:
    MinusPiDiv4 = -Math::PI / 4

		# A Vector where x is the tile width and y is the tile height.
		attr_reader :tile_size

		# A Vector where x is the horizontal tile count and y the vertical count.
		attr_reader :size

		# A Rectangle representing the region of the map that is currently
		# visible.
		attr_reader :cam

		# Creates a new map.
		#
		# Parameters:
		# [t_w] The width of the tiles.
		# [t_h] The height of the tiles.
		# [t_x_count] The horizontal count of tiles in the map.
		# [t_y_count] The vertical count of tiles in the map.
		# [scr_w] Width of the viewport for the map.
		# [scr_h] Height of the viewport for the map.
    # [isometric] Whether to use a isometric map. By default, an ortogonal map
    #             is used.
		# [limit_cam] Whether the camera should respect the bounds of the map
		#             (i.e., when given coordinates that would imply regions
		#             outside the map to appear in the screen, the camera would
		#             move to the nearest position where only the map shows up
		#             in the screen).
		def initialize t_w, t_h, t_x_count, t_y_count, scr_w = 800, scr_h = 600, isometric = false, limit_cam = true
			@tile_size = Vector.new t_w, t_h
			@size = Vector.new t_x_count, t_y_count
			@cam = Rectangle.new 0, 0, scr_w, scr_h
			@limit_cam = limit_cam
			@isometric = isometric
      if isometric
        initialize_isometric
      elsif limit_cam
        @max_x = t_x_count * t_w - scr_w
        @max_y = t_y_count * t_h - scr_h
      end
      set_camera 0, 0
		end

		# Returns a Vector with the total size of the map, in pixels (x for the
		# width and y for the height).
		def get_absolute_size
			return Vector.new(@tile_size.x * @size.x, @tile_size.y * @size.y) unless @isometric
			avg = (@size.x + @size.y) * 0.5
			Vector.new (avg * @tile_size.x).to_i, (avg * @tile_size.y).to_i
		end

		# Returns a Vector with the coordinates of the center of the map.
		def get_center
			abs_size = get_absolute_size
			Vector.new(abs_size.x * 0.5, abs_size.y * 0.5)
		end

		# Returns the position in the screen corresponding to the given tile
		# indices.
		#
		# Parameters:
		# [map_x] The index of the tile in the horizontal direction. It must be in
		#         the interval <code>0..t_x_count</code>.
		# [map_y] The index of the tile in the vertical direction. It must be in
		#         the interval <code>0..t_y_count</code>.
		def get_screen_pos map_x, map_y
			return Vector.new(map_x * @tile_size.x - @cam.x, map_y * @tile_size.y - @cam.y) unless @isometric
			Vector.new ((map_x - map_y - 1) * @tile_size.x * 0.5) - @cam.x + @x_offset,
			           ((map_x + map_y) * @tile_size.y * 0.5) - @cam.y
		end

		# Returns the tile in the map that corresponds to the given position in
		# the screen, as a Vector, where x is the horizontal index and y the
		# vertical index.
		#
		# Parameters:
		# [scr_x] The x-coordinate in the screen.
		# [scr_y] The y-coordinate in the screen.
		def get_map_pos scr_x, scr_y
			return Vector.new((scr_x + @cam.x) / @tile_size.x, (scr_y + @cam.y) / @tile_size.y) unless @isometric

      # Obtém a posição transformada para as coordenadas isométricas
			v = get_isometric_position scr_x, scr_y

			# Depois divide pelo tamanho do quadrado para achar a posição da matriz
			Vector.new((v.x * @inverse_square_size).to_i, (v.y * @inverse_square_size).to_i)
		end

		# Verifies whether a tile is inside the map.
		#
		# Parameters:
		# [v] A Vector representing the tile, with x as the horizontal index and
		#     y as the vertical index.
		def is_in_map v
			v.x >= 0 && v.y >= 0 && v.x < @size.x && v.y < @size.y
		end

		# Sets the top left corner of the viewport to the given position of the
		# map. Note that this is not the position in the screen.
		#
		# Parameters:
		# [cam_x] The x-coordinate inside the map, in pixels (not a tile index).
		# [cam_y] The y-coordinate inside the map, in pixels (not a tile index).
		def set_camera cam_x, cam_y
			@cam.x = cam_x
			@cam.y = cam_y
			set_bounds
		end

		# Moves the viewport by the given amount of pixels.
		#
		# Parameters:
		# [x] The amount of pixels to move horizontally. Negative values will
		#     cause the camera to move to the left.
		# [y] The amount of pixels to move vertically. Negative values will cause
		#     the camera to move up.
		def move_camera x, y
			@cam.x += x
			@cam.y += y
			set_bounds
		end

		# Iterates through the currently visible tiles, providing the horizontal
		# tile index, the vertical tile index, the x-coordinate (in pixels) and
		# the y-coordinate (in pixels), of each tile, in that order, to a given
		# block of code.
		#
		# Example:
		#
		#   map.foreach do |i, j, x, y|
		#     draw_tile tiles[i][j], x, y
		#   end
		def foreach
			for j in @min_vis_y..@max_vis_y
				for i in @min_vis_x..@max_vis_x
					pos = get_screen_pos i, j
					yield i, j, pos.x, pos.y
				end
			end
		end

	private

		def set_bounds
			if @isometric
        v1 = get_isometric_position(0, 0)
        v2 = get_isometric_position(@cam.w - 1, 0)
        v3 = get_isometric_position(@cam.w - 1, @cam.h - 1)
        v4 = get_isometric_position(0, @cam.h - 1)

        if @limit_cam
          if v1.x < -@max_offset
            offset = -(v1.x + @max_offset)
            @cam.x += offset * Sqrt2Div2
            @cam.y += offset * Sqrt2Div2 / @tile_ratio
            v1.x = -@max_offset
          end
          if v2.y < -@max_offset
            offset = -(v2.y + @max_offset)
            @cam.x -= offset * Sqrt2Div2
            @cam.y += offset * Sqrt2Div2 / @tile_ratio
            v2.y = -@max_offset
          end
          if v3.x > @iso_abs_size.x + @max_offset
            offset = v3.x - @iso_abs_size.x - @max_offset
            @cam.x -= offset * Sqrt2Div2
            @cam.y -= offset * Sqrt2Div2 / @tile_ratio
            v3.x = @iso_abs_size.x + @max_offset
          end
          if v4.y > @iso_abs_size.y + @max_offset
            offset = v4.y - @iso_abs_size.y - @max_offset
            @cam.x += offset * Sqrt2Div2
            @cam.y -= offset * Sqrt2Div2 / @tile_ratio
            v4.y = @iso_abs_size.y + @max_offset
          end
        end

        @min_vis_x = get_map_pos(0, 0).x
				@min_vis_y = get_map_pos(@cam.w - 1, 0).y
				@max_vis_x = get_map_pos(@cam.w - 1, @cam.h - 1).x
				@max_vis_y = get_map_pos(0, @cam.h - 1).y
			else
        if @limit_cam
          @cam.x = 0 if @cam.x < 0
          @cam.x = @max_x if @cam.x > @max_x
          @cam.y = 0 if @cam.y < 0
          @cam.y = @max_y if @cam.y > @max_y
        end
				@min_vis_x = @cam.x / @tile_size.x
				@min_vis_y = @cam.y / @tile_size.y
				@max_vis_x = (@cam.x + @cam.w - 1) / @tile_size.x
				@max_vis_y = (@cam.y + @cam.h - 1) / @tile_size.y
			end
      @cam.x = @cam.x.round
      @cam.y = @cam.y.round

			if @min_vis_y < 0; @min_vis_y = 0
			elsif @min_vis_y > @size.y - 1; @min_vis_y = @size.y - 1; end

			if @max_vis_y < 0; @max_vis_y = 0
			elsif @max_vis_y > @size.y - 1; @max_vis_y = @size.y - 1; end

			if @min_vis_x < 0; @min_vis_x = 0
			elsif @min_vis_x > @size.x - 1; @min_vis_x = @size.x - 1; end

			if @max_vis_x < 0; @max_vis_x = 0
			elsif @max_vis_x > @size.x - 1; @max_vis_x = @size.x - 1; end
		end

    def initialize_isometric
      @x_offset = (@size.y * 0.5 * @tile_size.x).round
      @tile_ratio = @tile_size.x.to_f / @tile_size.y
      square_size = @tile_size.x * Sqrt2Div2
      @inverse_square_size = 1 / square_size
      @iso_abs_size = Vector.new(square_size * @size.x, square_size * @size.y)
      a = (@size.x + @size.y) * 0.5 * @tile_size.x
      @isometric_offset_x = (a - square_size * @size.x) * 0.5
      @isometric_offset_y = (a - square_size * @size.y) * 0.5
      if @limit_cam
        actual_cam_h = @cam.h * @tile_ratio
        @max_offset = actual_cam_h < @cam.w ? actual_cam_h : @cam.w
        @max_offset *= Sqrt2Div2
      end
    end

    def get_isometric_position scr_x, scr_y
      # Escreve a posição em relação a origem (no centro do mapa)
      center = get_center
      position = Vector.new scr_x + @cam.x - center.x, scr_y + @cam.y - center.y

      # Multiplica por tile_ratio para obter tiles quadrados
      position.y *= @tile_ratio

      # O centro do mapa também é deslocado
      center.y *= @tile_ratio

      # Rotaciona o vetor posição -45°
      position.rotate! MinusPiDiv4

      # Retorna a referência da posição para o canto da tela
      position += center

      # O mapa quadrado está centralizado no centro do losango, precisa retornar ao canto da tela
      position.x -= @isometric_offset_x; position.y -= @isometric_offset_y
      position
    end
	end
end
