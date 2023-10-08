require_relative '../lib/minigl'

include MiniGL

class MyGame < GameWindow
  def initialize
    super(800, 600, false)
    @particles = Particles.new(x: 100, y: 100, shape: :square)
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
