require 'test/unit'
require_relative '../lib/minigl'
include AGL

class MovingObject
	include Movement
	def initialize x, y, w, h
		@x = x; @y = y; @w = w; @h = h
		@speed = Vector.new 0, 0
		@min_speed = Vector.new 0.01, 0.01
		@max_speed = Vector.new 1000, 1000
		@stored_forces = Vector.new 0, 0
	end
end

class MovementTest < Test::Unit::TestCase
	def setup
		@window = Gosu::Window.new 800, 600, false
		Game.initialize @window
		@obsts = [
			Block.new(-1, 0, 1, 600, false),
			Block.new(0, -1, 800, 1, false),
			Block.new(800, 0, 1, 600, false),
			Block.new(0, 600, 800, 1, false),
			Block.new(280, 560, 40, 40, true)
		]
		@ramps = [
			Ramp.new(600, 500, 200, 100, true),
			Ramp.new(0, 500, 200, 100, false)
		]
	end
	
	def test_fall
		o = MovingObject.new 480, 280, 40, 40
		forces = Vector.new 0, 0
		1000.times { o.move forces, @obsts, @ramps }
		assert_equal 480, o.x
		assert_equal 560, o.y
		assert_equal 0, o.speed.x
		assert_equal 0, o.speed.y
		assert_equal @obsts[3], o.bottom
	end
	
	def test_multiple_collision
		o = MovingObject.new 750, 10, 40, 40
		forces = Vector.new 50, -60
		o.move forces, @obsts, @ramps
		assert_equal 760, o.x
		assert_equal 0, o.y
		assert_equal 0, o.speed.x
		assert_equal 0, o.speed.y
		assert_equal @obsts[1], o.top
		assert_equal @obsts[2], o.right
	end
	
	def test_passable
		o = MovingObject.new 480, 560, 40, 40
		forces = Vector.new -250, 0
		o.move forces, @obsts, @ramps
		assert(o.x < @obsts[4].x)
	end
	
	def test_left_ramp
		o = MovingObject.new 380, 560, 40, 40
		forces = Vector.new 10, 0
		1000.times { o.move forces, @obsts, @ramps }
		assert_equal 760, o.x
		assert_equal 460, o.y
		assert_equal 0, o.speed.x
		assert_equal 0, o.speed.y
		assert_equal @obsts[2], o.right
		assert_equal @ramps[0], o.bottom
	end
	
	def test_right_ramp
		o = MovingObject.new 380, 560, 40, 40
		forces = Vector.new -10, 0
		1000.times { o.move forces, @obsts, @ramps }
		assert_equal 0, o.x
		assert_equal 460, o.y
		assert_equal 0, o.speed.x
		assert_equal 0, o.speed.y
		assert_equal @obsts[0], o.left
		assert_equal @ramps[1], o.bottom
	end
end
