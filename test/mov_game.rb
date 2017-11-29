require 'gosu'
require_relative '../lib/minigl'
include MiniGL

class MyGame < GameWindow
  def initialize
    super 800, 600, false

    @obj = GameObject.new(0, 0, 50, 50, :square)
    @obj2 = GameObject.new(100, 0, 50, 50, :square2)

    @obsts = [
      Block.new(0, 600, 800, 1, false),
      Block.new(-1, 0, 1, 600, false),
      Block.new(800, 0, 1, 600, false),
      Block.new(300, 430, 50, 50),
      # Block.new(375, 550, 50, 50, true),
      # Block.new(150, 200, 20, 300, false),
      # Block.new(220, 300, 100, 20, true),
      # Block.new(485, 490, 127, 10, false),
    ]
    @ramps = [
      Ramp.new(200, 550, 200, 50, true),
      Ramp.new(0, 200, 150, 300, false),
      Ramp.new(150, 500, 150, 100, false),
      Ramp.new(500, 500, 150, 100, true),
      Ramp.new(650, 300, 150, 200, true),
      Ramp.new(650, 500, 150, 100, true),
    ]

    # @cycle = [Vector.new(100, 530), Vector.new(650, 500)]
    # @cyc_obj = GameObject.new(@cycle[0].x, @cycle[0].y, 50, 50, :square)
    # @cyc_obj.instance_eval('@passable = true')
    # @obsts.push @cyc_obj
  end

  def update
    KB.update

    forces = Vector.new(0, 0)
    if @obj.bottom
      forces.y -= 15 if KB.key_pressed?(Gosu::KbSpace)
      forces.x -= 0.5 if KB.key_down?(Gosu::KbLeft)
      forces.x += 0.5 if KB.key_down?(Gosu::KbRight)
      forces.x -= @obj.speed.x * 0.1
    else
      forces.x -= 0.2 if KB.key_down?(Gosu::KbLeft)
      forces.x += 0.2 if KB.key_down?(Gosu::KbRight)
    end
    @obj.move(forces, @obsts, @ramps)

    speed = Vector.new(0, 0)
    speed.y -= 3 if KB.key_down? Gosu::KbW
    speed.y += 3 if KB.key_down? Gosu::KbS
    speed.x -= 3 if KB.key_down? Gosu::KbA
    speed.x += 3 if KB.key_down? Gosu::KbD
    @obj2.move(speed, @obsts, @ramps, true)
  end

  def draw
    @obj.draw
    @obj2.draw
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