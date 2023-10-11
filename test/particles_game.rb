require_relative '../lib/minigl'

include MiniGL

class MyGame < GameWindow
  def initialize
    super(800, 600, false)
    @particles_systems = [
      Particles.new(
        x: 100,
        y: 100,
        img: Res.img(:square),
        duration: 30,
        spread: 50,
        emission_rate: 5,
        emission_interval: 10,
        color: 0x00ffff,
        scale_change: :grow,
        alpha_change: :shrink,
        speed: { x: -1..1, y: -2..2 },
        rotation: 1,
        angle: 0..89
      ),
      Particles.new(
        x: 400,
        y: 100,
        shape: :triangle_down,
        spread: 50,
        emission_interval: 8,
        scale: 40,
        color: 0xffff00,
        alpha_change: :alternate,
      ),
    ]
    @particles_systems.each(&:start)
  end

  def update
    @particles_systems.each(&:update)
  end

  def draw
    @particles_systems.each(&:draw)
  end
end

MyGame.new.show
