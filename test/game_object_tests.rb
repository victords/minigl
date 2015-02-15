require 'test/unit'
require_relative '../lib/minigl'
include MiniGL

class SpriteTest < Test::Unit::TestCase
  def setup
    @window = GameWindow.new 800, 600, false
    Res.prefix = File.expand_path(File.dirname(__FILE__)) + '/data'
  end

  def test_sprite_position
    s = Sprite.new 10, 20, :image
    assert_equal 10, s.x
    assert_equal 20, s.y
    s = Sprite.new -100, 200, :image
    assert_equal -100, s.x
    assert_equal 200, s.y
  end

  def test_sprite_animation
    s = Sprite.new 10, 20, :image, 3, 1
    indices = [0, 1, 2]
    interval = 1
    3.times { s.animate indices, interval }
    assert_equal 0, s.img_index
    5.times { s.animate indices, interval }
    assert_equal 2, s.img_index
  end

  def test_sprite_visibility
    # m = Map.new(1, 1, 800, 600)
    s = Sprite.new 10, 20, :image, 3, 1 # the sprite will be 1 x 1 pixel
    assert s.visible?
    s.x = 800
    assert(!(s.visible?))
    s.x = -1
    assert(!(s.visible?))
    s.x = 0
    assert s.visible?
    s.y = 600
    assert(!(s.visible?))
  end
end

class GameObjectTest < Test::Unit::TestCase
  def setup
    @window = GameWindow.new 800, 600, false
    Res.prefix = File.expand_path(File.dirname(__FILE__)) + '/data'
  end

  def test_game_object_attributes
    o = GameObject.new 10, 20, 3, 1, :image
    assert_equal 10, o.x
    assert_equal 20, o.y
    assert_equal 3, o.w
    assert_equal 1, o.h
    assert_equal 0, o.speed.x
    assert_equal 0, o.speed.y
    assert_equal 0, o.stored_forces.x
    assert_equal 0, o.stored_forces.y
  end

  def test_game_object_animation
    o = GameObject.new 10, 20, 3, 1, :image, nil, 3, 1
    indices = [0, 1, 2]
    interval = 10
    5.times { o.animate indices, interval }
    assert_equal 0, o.img_index
    o.set_animation 0
    5.times { o.animate indices, interval }
    assert_equal 0, o.img_index
    5.times { o.animate indices, interval }
    assert_equal 1, o.img_index
  end

  def test_game_object_visibility
    # m = Map.new(1, 1, 800, 600)
    o = GameObject.new 10, 20, 30, 30, :square, Vector.new(-10, -10)
    assert o.visible?
    o.x = 800
    assert o.visible?
    o.x = 810
    assert(!(o.visible?))
    o.x = -30
    assert o.visible?
    o.y = -50
    assert(!(o.visible?))
    o.x = 0; o.y = -30
    assert o.visible?
    o.y = 610
    assert(!(o.visible?))
  end
end
