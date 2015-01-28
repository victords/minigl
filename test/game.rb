require_relative '../lib/minigl'
include MiniGL

class MyGame < Game
  def initialize
    super 800, 600, false

    @obj1 = GameObject.new 10, 10, 80, 80, :img1, Vector.new(-10, -10)
    @obj2 = Sprite.new 400, 0, :img1

    @font = Res.font :font1, 20
    @writer = TextHelper.new @font, 5
    @btn = Button.new(10, 560, @font, 'Test', :btn, 0x008000, 0x808080, 0xffffff, 0xff9980, true, false, 0, 4, 0, 0, 'friends') { |x| puts "hello #{x}" }
    @btn.enabled = false
    @chk =
      ToggleButton.new(40, 300, @font, 'Click me', :check, false, 0xffffff, 0x808080, 0x008000, 0xff9980, false, true, 36, 0, 0, 0, 'friends') { |c, x|
        puts "hello #{x}, checked: #{c}"
      }
    @txt = TextField.new(10, 520, @font, :text, nil, nil, 15, 5, 16, false, '', nil, 0, 0, 0x0000ff, 'test') { |t, x| puts "field #{x}, text: #{t}" }
    @txt.visible = false

    @pb = ProgressBar.new(5, 240, :barbg, :barfg, 3456, 70, 2, 2, @font, 0xff000080)
    @ddl = DropDownList.new(5, 270, @font, :btn, :btn, ['olá amigos', 'opção 2', 'terceira'], 0, 0, 0, 0, 0, 0x808080, 0xffffff, 0xffff00)
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
    @btn.enabled = !@btn.enabled if KB.key_pressed? Gosu::KbLeftControl
    @chk.checked = false if KB.key_pressed? Gosu::KbEscape
    @chk.enabled = !@chk.enabled if KB.key_pressed? Gosu::KbRightControl
    @txt.visible = !@txt.visible if KB.key_pressed? Gosu::KbReturn
    @txt.enabled = !@txt.enabled if KB.key_pressed? Gosu::KbLeftAlt
    @pb.visible = !@pb.visible if KB.key_pressed? Gosu::KbE
    @ddl.enabled = !@ddl.enabled if KB.key_pressed? Gosu::KbQ
    @ddl.visible = !@ddl.visible if KB.key_pressed? Gosu::KbW

    @pb.increase 1 if KB.key_down? Gosu::KbD
    @pb.decrease 1 if KB.key_down? Gosu::KbA
    @pb.percentage = 0.5 if KB.key_pressed? Gosu::KbS
    @pb.value = 10000 if KB.key_pressed? Gosu::KbZ

    @ddl.value = 'olá amigos' if KB.key_pressed? Gosu::Kb1
    @ddl.value = 'segunda' if KB.key_pressed? Gosu::Kb2
    @ddl.value = 'terceira' if KB.key_pressed? Gosu::Kb3

    Mouse.update
    if Mouse.double_click? :left
      @obj1.x = Mouse.x + 10
      @obj1.y = Mouse.y + 10
    end

    @btn.update
    @chk.update
    @txt.update
    @ddl.update
  end

  def draw
    clear 0xff000044

    @obj1.draw nil, 1, 1, 255, 0x33ff33, 30, 1
    @obj2.draw nil, 0.6, 1.4, 0x99
    @writer.write_breaking "Testing multiple line text.\nThis should draw text "\
                           'across multiple lines, respecting a limit width. '\
                           'Furthermore, the text must be right-aligned.',
                           780, 300, 300, :right, 0xff0000, 255, 1

    @btn.draw 0xcc
    @chk.draw
    @txt.draw
    @pb.draw
    @ddl.draw
  end
end

MyGame.new.show
