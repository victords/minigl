require 'test/unit'
require_relative '../lib/minigl'
include AGL

class MapTest < Test::Unit::TestCase
  def test_map_attributes
    m = Map.new 16, 16, 300, 200
    assert_equal 16, m.tile_size.x
    assert_equal 16, m.tile_size.y
    assert_equal 300, m.size.x
    assert_equal 200, m.size.y
    assert_equal 0, m.cam.x
    assert_equal 0, m.cam.y
    m = Map.new 25, 17, 49, 133
    assert_equal 25, m.tile_size.x
    assert_equal 17, m.tile_size.y
    assert_equal 49, m.size.x
    assert_equal 133, m.size.y
    assert_equal 0, m.cam.x
    assert_equal 0, m.cam.y
  end

  def test_absolute_size
    m = Map.new 16, 16, 300, 200
    v = m.get_absolute_size
    assert_equal 300 * 16, v.x
    assert_equal 200 * 16, v.y
  end

  def test_center
    m = Map.new 16, 16, 300, 200
    v = m.get_center
    assert_equal 300 * 16 / 2, v.x
    assert_equal 200 * 16 / 2, v.y
  end

  def test_screen_pos
    m = Map.new 16, 16, 300, 200
    v = m.get_screen_pos 8, 5
    assert_equal 8 * 16, v.x
    assert_equal 5 * 16, v.y
  end

  def test_map_pos
    m = Map.new 16, 16, 300, 200
    v = m.get_map_pos 410, 300
    assert_equal 25, v.x
    assert_equal 18, v.y
  end

  def test_in_map
    m = Map.new 16, 16, 300, 200
    assert m.is_in_map(Vector.new 30, 20)
    assert m.is_in_map(Vector.new 299, 199)
    assert !m.is_in_map(Vector.new 300, 200)
  end
end
