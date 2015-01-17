require 'test/unit'
require_relative '../lib/minigl'
include MiniGL

class VectorTest < Test::Unit::TestCase
  def test_vector_comparison
    v1 = Vector.new 1, 2
    v2 = v1.clone
    assert v1 == v2
    assert !(v1 != v2)

    v1 = Vector.new 1.37, 4.56
    v2 = Vector.new 1.373, 4.562
    assert v1.==(v2, 2)
    assert v1.!=(v2, 3)
  end

  def test_vector_operations
    v1 = Vector.new 1, 1
    v2 = Vector.new 2, 3

    v3 = v1 + v2
    assert_equal 3, v3.x
    assert_equal 4, v3.y

    v3 = v1 - v2
    assert_equal -1, v3.x
    assert_equal -2, v3.y

    v3 = v2 * 3
    assert_equal 6, v3.x
    assert_equal 9, v3.y

    v3 = v2 / 2
    assert_equal 1, v3.x
    assert_equal 1.5, v3.y

    v3 = Vector.new 0, Math.sqrt(2)
    assert v1.rotate(Math::PI / 4) == v3

    v1.rotate! Math::PI / 4
    assert v1 == v3
  end

  def test_vector_distance
    v1 = Vector.new 1, 1
    v2 = Vector.new 2, 3
    d = v1.distance v2
    assert_equal Math.sqrt(5), d

    v1 = Vector.new 0, 3
    v2 = Vector.new 4, 0
    d = v1.distance v2
    assert_equal 5, d
  end
end