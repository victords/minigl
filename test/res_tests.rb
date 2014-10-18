require 'test/unit'
require_relative '../lib/minigl'
include AGL

class ResTest < Test::Unit::TestCase
	def setup
		@window = Gosu::Window.new 800, 600, false
		Game.initialize @window
    Res.prefix = File.expand_path(File.dirname(__FILE__))
	end

	def test_tileset
		t1 = Res.tileset :tileset1
		assert_equal 9, t1.length
		assert_equal 32, t1[0].width
		assert_equal 32, t1[0].width
		Res.clear
		t1 = Res.tileset :tileset1, 48, 48
		assert_equal 4, t1.length
		assert_equal 48, t1[0].width
		assert_equal 48, t1[0].width
	end
end
