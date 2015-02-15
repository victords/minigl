require 'test/unit'
require_relative '../lib/minigl'
include MiniGL

class ResTest < Test::Unit::TestCase
  def setup
    @window = GameWindow.new 800, 600, false
    Res.prefix = File.expand_path(File.dirname(__FILE__)) + '/data'
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

  def test_dirs_and_separator
    assert_nothing_raised do
      img1 = Res.img :img1
    end
    Res.img_dir = 'img/sub'
    assert_nothing_raised do
      img2 = Res.img :image
    end
    Res.img_dir = 'img'
    Res.separator = '~'
    assert_nothing_raised do
      img3 = Res.img 'sub~image'
    end
  end
end
