require_relative '../lib/minigl'
include AGL

class MyGame < Gosu::Window
  def initialize
    super 800, 600, false # creating a 800 x 600 window, not full screen
    Game.initialize self, Vector.new(0, 1), 10, 2
    
    @obj1 = GameObject.new 10, 10, 80, 80, :img1, Vector.new(-10, -10)
    @obj2 = Sprite.new 400, 0, :img1
    
    @font = Res.font :font1, 20
    @writer = TextHelper.new @font, 5
    @btn = Button.new(10, 560, @font, "Test", :btn, 0x008000, 0, 0, 0, 0, 0, "friends") { |x| puts "hello #{x}" }
    @chk = ToggleButton.new(210, 560, @font, "Click me", :check, 0xffffffff, false, 36, 5, 0, 0, "friends") { |c, x| puts "hello #{x}, checked: #{c}" }
    @txt = TextField.new(10, 520, @font, :text, nil, 15, 5, 16, false, "", nil, 0, 0x0000ff, "test") { |x| puts "field #{x}" }
  end
  
  def needs_cursor?
    true
  end

  def update
    KB.update
    @obj1.y -= 1 if KB.key_held? Gosu::KbUp
    @obj1.x += 1 if KB.key_down? Gosu::KbRight
    @obj1.y += 1 if KB.key_held? Gosu::KbDown
    @obj1.x -= 1 if KB.key_down? Gosu::KbLeft
    @btn.set_position rand(700), rand(550) if KB.key_pressed? Gosu::KbSpace
    @chk.checked = false if KB.key_pressed? Gosu::KbEscape
    @txt.set_position rand(700), rand(550) if KB.key_pressed? Gosu::KbReturn
    
    Mouse.update
    if Mouse.double_click? :left
      @obj1.x = Mouse.x + 10
      @obj1.y = Mouse.y + 10
    end
    
    @btn.update
    @chk.update
    @txt.update
  end

  def draw
    @obj1.draw nil, 1, 1, 0x80, 0x33ff33, 30
    @obj2.draw nil, 0.6, 1.4, 0x99
    @writer.write_breaking "Testing multiple line text.\nThis should draw text "\
                           "across multiple lines, respecting a limit width. "\
                           "Furthermore, the text must be right-aligned.",
                           780, 300, 300, :right, 0xffffffff
    
    @btn.draw 0xcc
    @chk.draw
    @txt.draw
  end
end

game = MyGame.new
game.show
