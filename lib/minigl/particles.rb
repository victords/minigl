module MiniGL
  # A particle system.
  class Particles
    DEFAULT_OPTIONS = {
      emission_rate: 1,
      emission_interval: 60,
      duration: 30,
      shape: nil,
      img: nil,
      angle: nil,
      rotation: nil,
      color: 0xffffff,
    }.freeze

    def initialize(x:, y:, **options)
      raise "Particles must have either a shape or an image!" if options[:shape].nil? && options[:img].nil?

      @x = x
      @y = y
      @options = DEFAULT_OPTIONS.merge(options)

      @particles = []
      @emitting = false
    end

    def start
      set_emission_time
      @timer = @emission_time
      @emitting = true
    end

    def stop
      @emitting = false
    end

    def emitting?
      @emitting
    end

    def count
      @particles.size
    end

    def update
      @particles.each do |particle|
        particle.update
        @particles.delete(particle) if particle.dead?
      end
      return unless @emitting

      @timer += 1
      if @timer >= @emission_time
        @options[:emission_rate].times do
          @particles << Particle.new(x: @x,
                                     y: @y,
                                     duration: @options[:duration],
                                     shape: @options[:shape],
                                     img: @options[:img],
                                     **@options.slice(:angle, :rotation, :color))
        end
        set_emission_time
        @timer = 0
      end
    end

    def draw(map = nil, z_index = 0)
      @particles.each do |particle|
        particle.draw(map, 1, 255, z_index)
      end
    end

    private

    def set_emission_time
      interval = @options[:emission_interval]
      @emission_time = interval.is_a?(Range) ? rand(interval) : interval
    end

    class Particle
      DEFAULT_OPTIONS = {
        angle: nil,
        rotation: nil,
        speed: nil,
        color: 0xffffff,
      }.freeze

      def initialize(x:, y:, duration:, shape: nil, img: nil, **options)
        @x = x
        @y = y
        @duration = duration
        @shape = shape
        @img = img
        @options = DEFAULT_OPTIONS.merge(options)
        @angle = @options[:angle]
      end

      def dead?
        @duration <= 0
      end

      def update
        if @options[:rotation] && !@img.nil?
          @angle = 0 if @angle.nil?
          @angle += @options[:rotation]
          @angle -= 360 if @angle >= 360
        end

        if @options[:speed]
          @x += @options[:speed].x
          @y += @options[:speed].y
        end

        @duration -= 1
      end

      def draw(map, scale, alpha, z_index)
        x = @x - (map&.cam&.x || 0)
        y = @y - (map&.cam&.y || 0)
        color = (alpha << 24) | @options[:color]
        if @img
          if @angle
            @img.draw_rot(x, y, z_index, @angle, 0.5, 0.5, scale, scale, color)
          else
            @img.draw(x - @img.width * scale * 0.5, y - @img.height * scale * 0.5, z_index, scale, scale, color)
          end
        else
          case @shape
          when :square
            G.window.draw_rect(@x - scale * 0.5, @y - scale * 0.5, scale, scale, color, z_index)
          end
        end
      end
    end
  end
end
