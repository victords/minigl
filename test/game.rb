require_relative '../lib/minigl'
include MiniGL

class MyGame < Game
  def initialize
    super 800, 600, false

    @obj1 = GameObject.new 10, 10, 80, 80, :img1, Vector.new(-10, -10)
    @obj2 = Sprite.new 400, 0, :img1

    @font1 = Res.font :font1, 20
    @font2 = Res.font :font1, 50
    @writer1 = TextHelper.new @font1, 5
    @writer2 = TextHelper.new @font2, 5
    @btn = Button.new(10, 560, @font1, 'Test', :btn, 0x008000, 0x808080, 0xffffff, 0xff9980, true, false, 0, 4, 0, 0, 'friends') { |x| puts "hello #{x}" }
    @btn.enabled = false
    @chk =
      ToggleButton.new(40, 300, @font1, 'Click me', :check, false, 0xffffff, 0x808080, 0x008000, 0xff9980, false, true, 36, 0, 0, 0, 'friends') { |c, x|
        puts "hello #{x}, checked: #{c}"
      }
    @txt = TextField.new(10, 520, @font1, :text, nil, nil, 15, 5, 16, false, '', nil, 0, 0, 0x0000ff, 'test') { |t, x| puts "field #{x}, text: #{t}" }
    @txt.visible = false

    @pb = ProgressBar.new(5, 240, 200, 20, 0xff0000, 0x00ff00, 3456, 70, 0, 0, @font1, 0xff000080)
    @ddl = DropDownList.new(5, 270, @font1, nil, nil, ['olá amigos', 'opção 2', 'terceira'], 0, 3, 150, 25, 0, 0x808080, 0xffffff, 0xffff00)
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
    clear 0xffabcdef

    @obj1.draw nil, 1, 1, 255, 0x33ff33, 30, 1
    @obj2.draw nil, 0.6, 1.4, 0x99
    @writer1.write_line 'Testing effect 1', 400, 260, :center, 0xffffff, :border
    @writer2.write_line 'Second effect test', 400, 280, :center, 0xffffff, :border, 0xff0000, 2
    @writer2.write_line 'Text with shadow!!', 400, 340, :center, 0xffff00, :shadow, 0, 2, 0x80
    @writer1.write_breaking "Testing multiple line text.\nThis should draw text "\
                           'across multiple lines, respecting a limit width. '\
                           'Furthermore, the text must be right-aligned.',
                           780, 450, 300, :right, 0xff0000, 255, 1

    @ddl.draw 0x80, 1
    @btn.draw 0xcc
    @chk.draw
    @txt.draw
    @pb.draw 0x66
  end
end

MyGame.new.show
