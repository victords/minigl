require 'gosu'
require_relative '../lib/minigl'
include AGL

class MyGame < Game
  def initialize
    super 800, 600, false

    @obj = GameObject.new(0, 0, 50, 50, :square)
    @obsts = [
      Block.new(0, 600, 800, 1, false),
      Block.new(-1, 0, 1, 600, false),
      Block.new(800, 0, 1, 600, false),
      Block.new(375, 550, 50, 50, true),
      # Block.new(150, 200, 20, 300, false),
      Block.new(220, 300, 100, 20, true),
      Block.new(485, 490, 127, 10, false),
    ]
    @ramps = [
      Ramp.new(485, 330, 127, 160, true),
      Ramp.new(612, 230, 105, 100, true),
      # Ramp.new(717, 180, 83, 50, true),
      Ramp.new(700, 380, 100, 220, true),
      # Ramp.new(0, 200, 100, 50, false),
      Ramp.new(100, 250, 100, 100, false),
      Ramp.new(200, 350, 100, 250, false),
    ]
  end

  def update
    KB.update

    forces = Vector.new(0, 0)
    if @obj.bottom
      forces.y -= 15 if KB.key_pressed?(Gosu::KbSpace)
      if KB.key_down?(Gosu::KbLeft)
        forces.x -= 1.2
      elsif @obj.speed.x < 0
        @obj.speed.x *= 0.8
      end
      if KB.key_down?(Gosu::KbRight)
        forces.x += 1.2
      elsif @obj.speed.x > 0
        @obj.speed.x *= 0.8
      end
    else
      forces.x -= 0.2 if KB.key_down?(Gosu::KbLeft)
      forces.x += 0.2 if KB.key_down?(Gosu::KbRight)
    end
    @obj.move(forces, @obsts, @ramps)
  end

  def draw
    @obj.draw
    @obsts.each do |o|
      draw_quad o.x, o.y, 0xffffffff,
                o.x + o.w, o.y, 0xffffffff,
                o.x + o.w, o.y + o.h, 0xffffffff,
                o.x, o.y + o.h, 0xffffffff, 0
    end
    @ramps.each do |r|
      draw_triangle r.left ? r.x + r.w : r.x, r.y, 0xffffffff,
                    r.x + r.w, r.y + r.h, 0xffffffff,
                    r.x, r.y + r.h, 0xffffffff, 0
    end
  end
end

MyGame.new.show