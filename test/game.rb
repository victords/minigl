require_relative '../lib/minigl'
include MiniGL

class MyGame < GameWindow
  def initialize
    super 800, 600, false

    # @img = Res.img :img1
    @obj1 = GameObject.new 75, 75, 60, 60, :square3, Vector.new(-75, -75)
    @obj2 = Sprite.new 400, 0, :img1
    @obj3 = GameObject.new 4, 50, 24, 24, :check, Vector.new(-4, -4), 2, 4
    @obj3.set_animation 1
    @obj4 = Sprite.new 500, 0, :img1
    @objs = []
    8.times { @objs << GameObject.new(384, 284, 32, 32, :check, Vector.new(0, 0), 2, 4) }
    @flip = nil

    @font1 = Res.font :font1, 20
    @font2 = Res.font :font1, 50
    @writer1 = TextHelper.new @font1, 5
    @writer2 = TextHelper.new @font2, 5
    @btn = Button.new(10, 560, @font1, 'Test', :btn, 0x008000, 0x808080, 0xffffff, 0xff9980, true, true, 0, 4, 0, 0, 'friends', nil, 2, 2) { |x| puts "hello #{x}" }
    @btn.enabled = false
    @chk =
      ToggleButton.new(x: 0, y: 30, font: @font1, text: 'Click me', img: :check, center_x: false, margin_x: 36, params: 'friends', anchor: :south) { |c, x|
        puts "hello #{x}, checked: #{c}"
      }
    @txt = TextField.new(x: 0, y: 0, font: @font1, img: :text, margin_x: 15, margin_y: 5, max_length: 16, locale: 'PT-BR', scale_x: 1.2, scale_y: 0.8, anchor: :center_right)
    @txt.visible = false

    @pb = ProgressBar.new(50, 0, 200, 20, :barbg, :barfg, 3456, 70, 2, 2, @font1, 0xff000080, nil, nil, 1.8, 2, :center_left)
    @ddl = DropDownList.new(0, 10, @font1, nil, nil, ['olá amigos', 'opção 2', 'terceira'], 0, 3, 150, 25, 0, 0x808080, 0xffffff, 0xffff00, nil, 2, 2.5, :north) { |a, b|
      puts "mudou de #{a} para #{b}"
    }

    @panel = Panel.new(10, 10, 720, 520, [
      Button.new(x: 5, y: 5, font: @font1, text: 'Teste', img: :btn),
      Label.new(0, 70, @font1, 'Teste de label', 0x000066, 0x666666, 1, 1, :north),
      TextField.new(x: 5, y: 40, font: @font1, text: 'Opa', img: :text, margin_x: 5, margin_y: 5, anchor: :top_left),
      Button.new(x: 0, y: 5, font: @font1, text: 'Teste', img: :btn, anchor: :top),
      DropDownList.new(x: 0, y: 40, width: 150, height: 25, font: @font1, options: ['olá amigos', 'opção 2', 'terceira'], anchor: :north),
      Button.new(x: 5, y: 5, font: @font1, text: 'Teste', img: :btn, anchor: :northeast),
      Button.new(x: 5, y: 0, font: @font1, text: 'Teste', img: :btn, anchor: :left),
      Button.new(x: 0, y: 0, font: @font1, text: 'Teste', img: :btn, anchor: :center),
      Button.new(x: 5, y: 0, font: @font1, text: 'Teste', img: :btn, anchor: :right),
      ToggleButton.new(x: 5, y: 40, img: :check, center_x: false, margin_x: 36, anchor: :east),
      Button.new(x: 5, y: 5, font: @font1, text: 'Teste', img: :btn, anchor: :southwest),
      Button.new(x: 0, y: 5, font: @font1, text: 'Teste', img: :btn, anchor: :south),
      ProgressBar.new(0, 40, 200, 20, :barbg, :barfg, 3456, 70, 2, 2, @font1, 0xff000080, nil, nil, 1, 1, :bottom)
    ], :text, :tiled, true, 2, 2, :bottom_right)

    @eff = Effect.new(100, 100, :check, 2, 4, 10, nil, nil, '1')

    @angle = 0
  end

  def needs_cursor?
    true
  end

  def update
    KB.update
    begin @obj1.y -= 0.714; @obj4.y -= 0.714 end if KB.key_held? Gosu::KbUp
    begin @obj1.x += 0.714; @obj4.x += 0.714 end if KB.key_down? Gosu::KbRight
    begin @obj1.y += 0.714; @obj4.y += 0.714 end if KB.key_held? Gosu::KbDown
    begin @obj1.x -= 0.714; @obj4.x -= 0.714 end if KB.key_down? Gosu::KbLeft
    @btn.set_position rand(700), rand(550) if KB.key_pressed? Gosu::KbSpace
    @btn.enabled = !@btn.enabled if KB.key_pressed? Gosu::KbLeftControl
    @chk.checked = false if KB.key_pressed? Gosu::KbEscape
    @chk.enabled = !@chk.enabled if KB.key_pressed? Gosu::KbRightControl
    @txt.visible = !@txt.visible if KB.key_pressed? Gosu::KbReturn
    @txt.enabled = !@txt.enabled if KB.key_pressed? Gosu::KbLeftAlt
    @txt.locale = 'en-us' if KB.key_pressed? Gosu::KbX
    @txt.locale = 'pt-br' if KB.key_pressed? Gosu::KbC
    @pb.visible = !@pb.visible if KB.key_pressed? Gosu::KbE
    @ddl.enabled = !@ddl.enabled if KB.key_pressed? Gosu::KbQ
    @ddl.visible = !@ddl.visible if KB.key_pressed? Gosu::KbW
    @panel.enabled = !@panel.enabled if KB.key_pressed? Gosu::KbN
    @panel.visible = !@panel.visible if KB.key_pressed? Gosu::KbM

    @panel.add_component(Button.new(x: 5, y: 5, font: @font1, text: 'Teste', img: :btn, anchor: :southeast)) if KB.key_pressed?(Gosu::KbB)

    @pb.increase 1 if KB.key_down? Gosu::KbD
    @pb.decrease 1 if KB.key_down? Gosu::KbA
    @pb.percentage = 0.5 if KB.key_pressed? Gosu::KbS
    @pb.value = 10000 if KB.key_pressed? Gosu::KbZ

    @ddl.value = 'olá amigos' if KB.key_pressed? Gosu::Kb1
    @ddl.value = 'segunda' if KB.key_pressed? Gosu::Kb2
    @ddl.value = 'terceira' if KB.key_pressed? Gosu::Kb3

    G.window.toggle_fullscreen if KB.key_pressed?(Gosu::KB_RIGHT_ALT)

    Mouse.update
    if Mouse.double_click? :left
      @obj1.x = Mouse.x
      @obj1.y = Mouse.y
    end
    if Mouse.button_released? :right
      if @flip.nil?; @flip = :horiz
      else; @flip = nil; end
    end
    if Mouse.button_down? :left
      @angle += 1
    end

    @btn.update
    @chk.update
    @txt.update
    @ddl.update

    @panel.update

    @eff.update

    @objs.each_with_index do |o, i|
      o.move_free(i * 45, 3)
    end
  end

  def draw
    clear 0xabcdef

    # @img.draw_rot 400, 100, 0, @angle, 1, 1
    @obj1.draw color: 0x33ff33, angle: (@angle == 0 ? nil : @angle), scale_x: 1.5, scale_y: 1.5
    @obj2.draw angle: (@angle == 0 ? nil : @angle), scale_x: 0.5, scale_y: 1.4
    @obj3.draw flip: @flip
    @obj4.draw round: true
    @objs.each { |o| o.draw }
    @writer1.write_line text: 'Testing effect 1', x: 400, y: 260, color: 0xffffff, effect: :border
    @writer2.write_line 'Second effect test', 400, 280, :center, 0xffffff, 255, :border, 0xff0000, 2
    @writer2.write_line 'Text with shadow!!', 400, 340, :center, 0xffff00, 255, :shadow, 0, 2, 0x80
    @writer1.write_breaking "Testing multiple line text.\nThis should draw text "\
                            'across multiple lines, respecting a limit width. '\
                            'Furthermore, the text must be right-aligned.',
                            780, 450, 300, :right, 0xff0000, 255, 1

    @ddl.draw 0x80, 1, 0xff8080
    @btn.draw 0xcc, 1, 0x33ff33
    @chk.draw
    @txt.draw
    @pb.draw 0x66

    @panel.draw(204, 10)

    @eff.draw
  end
end

MyGame.new.show
