require_relative '../lib/minigl'

include MiniGL

class CollisionTest < GameWindow
  def initialize
    super(300, 300, false)

    @object = GameObject.new(0, 150, 50, 50, :img1)
    @object.max_speed.x = @object.max_speed.y = 1000
    @blocks = [
      Block.new(0, 0, 100, 100),
      Block.new(100, 0, 100, 100),
      Block.new(200, 100, 100, 100),
      Block.new(200, 200, 100, 100),
    ]
  end

  def update
    KB.update

    forces = Vector.new
    if KB.key_pressed?(Gosu::KB_Z)
      @object.x = 0
      @object.y = 150
    end
    forces = Vector.new(60, -100) if KB.key_pressed?(Gosu::KB_X)
    if KB.key_pressed?(Gosu::KB_C)
      @object.x = 100
      @object.y = 250
    end
    forces = Vector.new(100, -60) if KB.key_pressed?(Gosu::KB_V)
    if KB.key_pressed?(Gosu::KB_B)
      @object.x = 100
      @object.y = 150
    end

    @object.move(forces, @blocks, [], true)
  end

  def draw
    @blocks.each_with_index do |block, i|
      draw_rect(block.x, block.y, block.w, block.h, i.even? ? 0xffffffff : 0xffcccccc)
    end
    draw_rect(@object.x, @object.y, @object.w, @object.h, 0xffffffff)
  end
end

CollisionTest.new.show
