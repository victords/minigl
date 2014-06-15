require_relative '../lib/minigl'
include AGL

class MyGame < Gosu::Window
  def initialize
    super 800, 600, false # creating a 800 x 600 window, not full screen
    Game.initialize self, Vector.new(0, 1), 10, 2, 20
    
    @img = Res.img :img1
    @font = Res.font :font1, 20
    @writer = TextHelper.new @font, 5
    @x = 0
    @y = 0
  end
  
  def needs_cursor?
    true
  end

  def update
    KB.update
    @y -= 1 if KB.key_held? Gosu::KbUp
    @x += 1 if KB.key_down? Gosu::KbRight
    @y += 1 if KB.key_held? Gosu::KbDown
    @x -= 1 if KB.key_down? Gosu::KbLeft
    
    Mouse.update
    if Mouse.double_click? :left
      @x = Mouse.x - @img.width / 2
      @y = Mouse.y - @img.height / 2
    end
  end

  def draw
    @img.draw @x, @y, 0
    @writer.write_breaking "Testing multiple line text.\nThis should draw text "\
                           "across multiple lines, respecting a limit width. "\
                           "Furthermore, the text must be right-aligned.",
                           780, 300, 300, :right
  end
end

game = MyGame.new
game.show
