require_relative '../lib/minigl'

include MiniGL

class MyGame < GameWindow
  def initialize
    super(800, 600, false)
    @particles = Particles.new(
      x: 100,
      y: 100,
      img: Res.img(:square),
      duration: 30,
      spread: 50,
      emission_rate: 5,
      emission_interval: 10,
      color: 0x00ffff,
      alpha_change: :shrink,
      alpha_min: 0,
      alpha_max: 255,
      speed: { x: -1..1, y: -2..2 },
      rotation: 1,
      angle: 0..89
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
