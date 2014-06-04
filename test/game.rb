require_relative '../lib/minigl'
include AGL

class MyGame < Gosu::Window
  def initialize
    super 800, 600, false # creating a 800 x 600 window, not full screen
    Game.initialize self  # initializing MiniGL for this window
    
    @img = Res.img :img1
    @font = Res.font :font1, 20
    @x = 0
    @y = 0
  end
  
  def needs_cursor?
    true
  end

  def update
    KB.update
    @y -= 1 if KB.key_down? Gosu::KbUp
    @x += 1 if KB.key_down? Gosu::KbRight
    @y += 1 if KB.key_down? Gosu::KbDown
    @x -= 1 if KB.key_down? Gosu::KbLeft
    
    Mouse.update
    if Mouse.button_pressed? :left
      @x = Mouse.x - @img.width / 2
      @y = Mouse.y - @img.height / 2
    end
  end

  def draw
    @img.draw @x, @y, 0
    @font.draw "Testing fonts", 20, 560, 0
  end
end

game = MyGame.new
game.show
