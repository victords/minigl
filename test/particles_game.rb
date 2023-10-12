require_relative '../lib/minigl'

include MiniGL

class MyGame < GameWindow
  def initialize
    super(800, 600, false)
    @source = Sprite.new(100, 100, :btn)
    @particles_systems = [
      Particles.new(
        source: @source,
        source_offset_x: 50,
        source_offset_y: 120,
        img: Res.img(:square),
        duration: 30,
        spread: 50,
        emission_rate: 5,
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
        emission_rate: 1..3,
        scale: 40,
        color: 0xffff00,
        alpha_change: :alternate,
      ),
    ]
    @particles_systems.each(&:start)
  end

  def update
    KB.update
    @source.x -= 3 if KB.key_down?(Gosu::KB_LEFT)
    @source.x += 3 if KB.key_down?(Gosu::KB_RIGHT)
    @source.y -= 3 if KB.key_down?(Gosu::KB_UP)
    @source.y += 3 if KB.key_down?(Gosu::KB_DOWN)

    if KB.key_pressed?(Gosu::KB_SPACE)
      if @particles_systems[1].emitting?
        @particles_systems[1].stop
      else
        @particles_systems[1].start
      end
    end

    if KB.key_pressed?(Gosu::KB_Q)
      @particles_systems[1].move_to(50, 500)
    end

    @particles_systems.each(&:update)
  end

  def draw
    @source.draw
    @particles_systems.each(&:draw)
  end
end

MyGame.new.show
