require_relative 'global'

module AGL
	# Represents an object with a rectangular bounding box and the +passable+
	# property. It is the simplest structure that can be passed as an element of
	# the +obst+ array parameter of the +move+ method.
	class Block
		# The x-coordinate of the top left corner of the bounding box.
		attr_reader :x
		
		# The y-coordinate of the top left corner of the bounding box.
		attr_reader :y
		
		# The width of the bounding box.
		attr_reader :w
		
		# The height of the bounding box.
		attr_reader :h
		
		# Whether a moving object can pass through this block when coming from
		# below. This is a common feature of platforms in platform games.
		attr_reader :passable
		
		# Creates a new block.
		# 
		# Parameters:
		# [x] The x-coordinate of the top left corner of the bounding box.
		# [y] The y-coordinate of the top left corner of the bounding box.
		# [w] The width of the bounding box.
		# [h] The height of the bounding box.
		# [passable] Whether a moving object can pass through this block when
		# coming from below. This is a common feature of platforms in platform
		# games.
		def initialize x, y, w, h, passable
			@x = x; @y = y; @w = w; @h = h
			@passable = passable
		end
		
		# Returns the bounding box of this block as a Rectangle.
		def bounds
			Rectangle.new @x, @y, @w, @h
		end
	end
	
	# Represents a ramp, i.e., an inclined structure which allows walking over
	# it while automatically going up or down. It can be imagined as a right
	# triangle, with a side parallel to the x axis and another one parallel to
	# the y axis. You must provide instances of this class (or derived classes)
	# to the +ramps+ array parameter of the +move+ method.
	class Ramp
		# The x-coordinate of the top left corner of a rectangle that completely
		# (and precisely) encloses the ramp (thought of as a right triangle).
		attr_reader :x
		
		# The y-coordinate of the top left corner of the rectangle described in
		# the +x+ attribute.
		attr_reader :y
		
		# The width of the ramp.
		attr_reader :w
		
		# The height of the ramp.
		attr_reader :h
		
		# Whether the height of the ramp increases from left to right (decreases
		# from left to right when +false+).
		attr_reader :left
		
		# Creates a new ramp.
		# 
		# Parameters:
		# [x] The x-coordinate of the top left corner of a rectangle that
		#     completely (and precisely) encloses the ramp (thought of as a right
		#     triangle).
		# [y] The y-coordinate of the top left corner of the rectangle described
		#     above.
		# [w] The width of the ramp (which corresponds to the width of the
		#     rectangle described above).
		# [h] The height of the ramp (which corresponds to the height of the
		#     rectangle described above, and to the difference between the lowest
		#     point of the ramp, where it usually meets the floor, and the
		#     highest).
		# [left] Whether the height of the ramp increases from left to right. Use
		#        +false+ for a ramp that goes down from left to right.
		def initialize x, y, w, h, left
			@x = x
			@y = y
			@w = w
			@h = h
			@left = left
		end
		
		# Checks if an object is in contact with this ramp (standing over it).
		# 
		# Parameters:
		# [obj] The object to check contact with. It must have the +x+, +y+, +w+
		#       and +h+ accessible attributes determining its bounding box.
		def contact? obj
			obj.x.round(6) == get_x(obj).round(6) && obj.y.round(6) == get_y(obj).round(6)
		end
		
		# Checks if an object is intersecting this ramp (inside the corresponding
		# right triangle and at the floor level or above).
		# 
		# Parameters:
		# [obj] The object to check intersection with. It must have the +x+, +y+,
		#       +w+ and +h+ accessible attributes determining its bounding box.
		def intersects obj
			obj.x + obj.w > @x && obj.x < @x + @w && obj.y > get_y(obj) && obj.y <= @y + @h - obj.h
		end
		
		# :nodoc:
		def can_collide? obj
			@can_collide = (obj.speed.y >= 0 and not intersects(obj))
		end
		
		def check_intersection obj
			if @can_collide and intersects obj
				obj.y = get_y obj
				obj.speed.y = 0
#				a = @w / @h
#				x = get_x(obj)
#				y = get_y(obj)
#				w = obj.x - x
#				h = obj.y - y
#				dx = w * h / (w * a + h)
#				dy = dx * a
#				
#				obj.x -= dx
#				obj.y -= dy
#				obj.speed.x *= (@w / (@w + @h))
#				obj.speed.y = 0
			end
		end
		
		def get_x obj
			return @x + (1.0 * (@y + @h - obj.y - obj.h) * @w / @h) - obj.w if @left
			@x + (1.0 * (obj.y + obj.h - @y) * @w / @h)
		end
		
		def get_y obj
			return @y - obj.h if @left && obj.x + obj.w > @x + @w
			return @y + (1.0 * (@x + @w - obj.x - obj.w) * @h / @w) - obj.h if @left
			return @y - obj.h if obj.x < @x
			@y + (1.0 * (obj.x - @x) * @h / @w) - obj.h
		end
	end
	
	# This module provides objects with physical properties and methods for
	# moving. It allows moving with or without collision checking (based on
	# rectangular bounding boxes), including a method to behave as an elevator,
	# affecting other objects' positions as it moves.
	module Movement
		# The mass of the object, in arbitrary units. The default value for
		# GameObject instances, for example, is 1. The larger the mass (i.e., the
		# heavier the object), the more intense the forces applied to the object
		# have to be in order to move it.
		attr_reader :mass
		
		# A Vector with the current speed of the object (x: horizontal component,
		# y: vertical component).
		attr_reader :speed
		
		# Width of the bounding box.
		attr_reader :w
		
		# Height of the bounding box.
		attr_reader :h
		
		# Whether a moving object can pass through this block when coming from
		# below. This is a common feature of platforms in platform games.
		attr_reader :passable
		
		# The object that is making contact with this from above. If there's no
		# contact, returns +nil+.
		attr_reader :top
		
		# The object that is making contact with this from below. If there's no
		# contact, returns +nil+.
		attr_reader :bottom
		
		# The object that is making contact with this from the left. If there's no
		# contact, returns +nil+.
		attr_reader :left
		
		# The object that is making contact with this from the right. If there's
		# no contact, returns +nil+.
		attr_reader :right
		
		# The x-coordinate of the top left corner of the bounding box.
		attr_accessor :x
		
		# The y-coordinate of the top left corner of the bounding box.
		attr_accessor :y
		
		# A Vector with the horizontal and vertical components of a force that
		# be applied in the next time +move+ is called.
		attr_accessor :stored_forces
		
		# Returns the bounding box as a Rectangle.
		def bounds
			Rectangle.new @x, @y, @w, @h
		end
		
		# Moves this object, based on the forces being applied to it, and
		# performing collision checking.
		# 
		# Parameters:
		# [forces] A Vector where x is the horizontal component of the resulting
		#          force and y is the vertical component.
		# [obst] An array of obstacles to be considered in the collision checking.
		#        Obstacles must be instances of Block (or derived classes), or
		#        objects that <code>include Movement</code>.
		# [ramps] An array of ramps to be considered in the collision checking.
		#         Ramps must be instances of Ramp (or derived classes).
		def move forces, obst, ramps
			forces.x += Game.gravity.x; forces.y += Game.gravity.y
			forces.x += @stored_forces.x; forces.y += @stored_forces.y
			@stored_forces.x = @stored_forces.y = 0
			
			# check_contact obst, ramps
			forces.x = 0 if (forces.x < 0 and @left) or (forces.x > 0 and @right)
			forces.y = 0 if (forces.y < 0 and @top) or (forces.y > 0 and @bottom)
			
			@speed.x += forces.x / @mass; @speed.y += forces.y / @mass
			@speed.x = 0 if @speed.x.abs < @min_speed.x
			@speed.y = 0 if @speed.y.abs < @min_speed.y
			@speed.x = (@speed.x <=> 0) * @max_speed.x if @speed.x.abs > @max_speed.x
			@speed.y = (@speed.y <=> 0) * @max_speed.y if @speed.y.abs > @max_speed.y
			
			ramps.each do |r|
				r.can_collide? self
			end
			
			x = @speed.x < 0 ? @x + @speed.x : @x
			y = @speed.y < 0 ? @y + @speed.y : @y
			w = @w + (@speed.x < 0 ? -@speed.x : @speed.x)
			h = @h + (@speed.y < 0 ? -@speed.y : @speed.y)
			move_bounds = Rectangle.new x, y, w, h
			coll_list = []
			obst.each do |o|
				coll_list << o if move_bounds.intersects o.bounds
			end
		
			if coll_list.length > 0
				up = @speed.y < 0; rt = @speed.x > 0; dn = @speed.y > 0; lf = @speed.x < 0
				if @speed.x == 0 || @speed.y == 0
					# Ortogonal
					if rt; x_lim = find_right_limit coll_list
					elsif lf; x_lim = find_left_limit coll_list
					elsif dn; y_lim = find_down_limit coll_list
					elsif up; y_lim = find_up_limit coll_list
					end
					if rt && @x + @w + @speed.x > x_lim; @x = x_lim - @w; @speed.x = 0
					elsif lf && @x + @speed.x < x_lim; @x = x_lim; @speed.x = 0
					elsif dn && @y + @h + @speed.y > y_lim; @y = y_lim - @h; @speed.y = 0
					elsif up && @y + @speed.y < y_lim; @y = y_lim; @speed.y = 0
					end
				else
					# Diagonal
					x_aim = @x + @speed.x + (rt ? @w : 0); x_lim_def = x_aim
					y_aim = @y + @speed.y + (dn ? @h : 0); y_lim_def = y_aim
					coll_list.each do |c|
						if c.passable; x_lim = x_aim
						elsif rt; x_lim = c.x
						else; x_lim = c.x + c.w
						end
						if dn; y_lim = c.y
						elsif c.passable; y_lim = y_aim
						else; y_lim = c.y + c.h
						end
					
						if c.passable
							y_lim_def = y_lim if dn && @y + @h <= y_lim && y_lim < y_lim_def
						elsif (rt && @x + @w > x_lim) || (lf && @x < x_lim)
							# Can't limit by x, will limit by y
							y_lim_def = y_lim if (dn && y_lim < y_lim_def) || (up && y_lim > y_lim_def)
						elsif (dn && @y + @h > y_lim) || (up && @y < y_lim)
							# Can't limit by y, will limit by x 
							x_lim_def = x_lim if (rt && x_lim < x_lim_def) || (lf && x_lim > x_lim_def)
						else
							xTime = 1.0 * (x_lim - @x - (@speed.x < 0 ? 0 : @w)) / @speed.x
							yTime = 1.0 * (y_lim - @y - (@speed.y < 0 ? 0 : @h)) / @speed.y
							if xTime > yTime
								# Will limit by x
								x_lim_def = x_lim if (rt && x_lim < x_lim_def) || (lf && x_lim > x_lim_def)
							elsif (dn && y_lim < y_lim_def) || (up && y_lim > y_lim_def)
								y_lim_def = y_lim
							end
						end
					end
					if x_lim_def != x_aim
						@speed.x = 0
						if lf; @x = x_lim_def
						else; @x = x_lim_def - @w
						end
					end
					if y_lim_def != y_aim
						@speed.y = 0
						if up; @y = y_lim_def
						else; @y = y_lim_def - @h
						end
					end
				end
			end
			@x += @speed.x
			@y += @speed.y
			
			ramps.each do |r|
				r.check_intersection self
			end
			check_contact obst, ramps
		end
		
		# Moves this object as an elevator (i.e., potentially carrying other
		# objects) towards a given point.
		# 
		# Parameters:
		# [aim] A Vector specifying where the object will move to.
		# [speed] The constant speed at which the object will move. This must be
		#         provided as a scalar, not a vector.
		# [obstacles] An array of obstacles to be considered in the collision
		#             checking, and carried along when colliding from above.
		#             Obstacles must be instances of Block (or derived classes),
		#             or objects that <code>include Movement</code>.
		def move_carrying aim, speed, obstacles
			x_d = aim.x - @x; y_d = aim.y - @y
			distance = Math.sqrt(x_d**2 + y_d**2)
			@speed.x = 1.0 * x_d * speed / distance
			@speed.y = 1.0 * y_d * speed / distance
			
			x_aim = @x + @speed.x; y_aim = @y + @speed.y
			passengers = []
			obstacles.each do |o|
				if @x + @w > o.x && o.x + o.w > @x
					foot = o.y + o.h
					if foot.round(6) == @y.round(6) || @speed.y < 0 && foot < @y && foot > y_aim
						passengers << o
					end
				end
			end
		
			if @speed.x > 0 && x_aim >= aim.x || @speed.x < 0 && x_aim <= aim.x
				passengers.each do |p| p.x += aim.x - @x end
				@x = aim.x; @speed.x = 0
			else
				passengers.each do |p| p.x += @speed.x end
				@x = x_aim
			end
			if @speed.y > 0 && y_aim >= aim.y || @speed.y < 0 && y_aim <= aim.y
				@y = aim.y; @speed.y = 0
			else
				@y = y_aim
			end
		
			passengers.each do |p| p.y = @y - p.h end
		end
		
		# Moves this object, without performing any collision checking, towards
		# the specified point.
		# 
		# Parameters:
		# [aim] A Vector specifying where the object will move to.
		# [speed] The constant speed at which the object will move. This must be
		#         provided as a scalar, not a vector.
		def move_free aim, speed
			x_d = aim.x - @x; y_d = aim.y - @y
			distance = Math.sqrt(x_d**2 + y_d**2)
			@speed.x = 1.0 * x_d * speed / distance
			@speed.y = 1.0 * y_d * speed / distance
		
			if (@speed.x < 0 and @x + @speed.x <= aim.x) or (@speed.x >= 0 and @x + @speed.x >= aim.x)
				@x = aim.x
				@speed.x = 0
			else
				@x += @speed.x
			end

			if (@speed.y < 0 and @y + @speed.y <= aim.y) or (@speed.y >= 0 and @y + @speed.y >= aim.y)
				@y = aim.y
				@speed.y = 0
			else
				@y += @speed.y
			end
		end
		
		# Causes the object to move in cycles across multiple given points (the
		# method must be called repeatedly, and it returns the value that must be
		# provided to +cur_point+ after the first call). If obstacles are
		# provided, it will behave as an elevator (as in +move_carrying+).
		# 
		# Parameters:
		# [points] An array of Vectors representing the path that the object will
		#          perform.
		# [cur_point] The index of the point in the path that the object is
		#             currently moving to. In the first call, it is a good idea to
		#             provide 0, while in the subsequent calls, you must provide
		#             the return value of this method.
		# [speed] The constant speed at which the object will move. This must be
		#         provided as a scalar, not a vector.
		# [obstacles] An array of obstacles to be considered in the collision
		#             checking, and carried along when colliding from above.
		#             Obstacles must be instances of Block (or derived classes),
		#             or objects that <code>include Movement</code>.
		def cycle points, cur_point, speed, obstacles = nil
			if obstacles
				move_carrying points[cur_point], speed, obstacles
			else
				move_free points[cur_point], speed
			end
			if @speed.x == 0 and @speed.y == 0
				if cur_point == points.length - 1; cur_point = 0
				else; cur_point += 1; end
			end
			cur_point
		end
		
	private
		
		def check_contact obst, ramps
			@top = @bottom = @left = @right = nil
			obst.each do |o|
				x2 = @x + @w; y2 = @y + @h; x2o = o.x + o.w; y2o = o.y + o.h
				@right = o if !o.passable && x2.round(6) == o.x.round(6) && y2 > o.y && @y < y2o
				@left = o if !o.passable && @x.round(6) == x2o.round(6) && y2 > o.y && @y < y2o
				@bottom = o if y2.round(6) == o.y.round(6) && x2 > o.x && @x < x2o
				@top = o if !o.passable && @y.round(6) == y2o.round(6) && x2 > o.x && @x < x2o
			end		
			if @bottom.nil?
				ramps.each do |r|
					if r.contact? self
						@bottom = r
						break
					end
				end
			end
		end
		
		def find_right_limit coll_list
			limit = @x + @w + @speed.x
			coll_list.each do |c|
				limit = c.x if !c.passable && c.x < limit
			end
			limit
		end
		
		def find_left_limit coll_list
			limit = @x + @speed.x
			coll_list.each do |c|
				limit = c.x + c.w if !c.passable && c.x + c.w > limit
			end
			limit
		end
		
		def find_down_limit coll_list
			limit = @y + @h + @speed.y
			coll_list.each do |c|
				limit = c.y if c.y < limit && c.y >= @y + @h
			end
			limit
		end
		
		def find_up_limit coll_list
			limit = @y + @speed.y
			coll_list.each do |c|
				limit = c.y + c.h if !c.passable && c.y + c.h > limit
			end
			limit
		end
	end
end
