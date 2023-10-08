require_relative '../lib/minigl'

include MiniGL

class MyGame < GameWindow
  def initialize
    super(800, 600, false)
    @particles = Particles.new(
      x: 100,
      y: 100,
      shape: :square,
      duration: 30,
      color: 0x00ffff,
      scale: 80,
      alpha_change: :shrink,
      alpha_min: 0,
      alpha_max: 255,
    )
    @particles.start
  end

  def update
    @particles.update
  end

  def draw
    @particles.draw
  end
end

MyGame.new.show
