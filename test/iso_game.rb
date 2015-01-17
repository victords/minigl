require_relative '../lib/minigl'
include MiniGL

class MyGame < Gosu::Window
  def initialize
    super 800, 600, false
    Game.initialize self

    @tile1 = Res.img :tile2
    @tile2 = Res.img :tile2b
    @map = Map.new 25, 17, 200, 200, 800, 600, true
    @p = Vector.new -1, -1
  end

  def needs_cursor?
    true
  end

  def update
    KB.update
    Mouse.update
    p = @map.get_map_pos Mouse.x, Mouse.y
    @p = p if @map.is_in_map p

    @map.move_camera 0, -4.5 if KB.key_down? Gosu::KbUp
    @map.move_camera 4.5, 0 if KB.key_down? Gosu::KbRight
    @map.move_camera 0, 4.5 if KB.key_down? Gosu::KbDown
    @map.move_camera -4.5, 0 if KB.key_down? Gosu::KbLeft
    @map.set_camera 0, 0 if KB.key_down? Gosu::KbReturn
  end

  def draw
    @map.foreach do |i, j, x, y|
      if i == @p.x and j == @p.y; @tile2.draw x, y, 0
      else; @tile1.draw x, y, 0; end
    end
  end
end

MyGame.new.show
