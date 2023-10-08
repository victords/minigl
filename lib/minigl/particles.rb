module MiniGL
  # A particle system.
  class Particles
    DEFAULT_OPTIONS = {
      emission_rate: 1,
      emission_interval: 60,
      duration: 30,
      shape: nil,
      img: nil,
      spread: 0,
      scale: 1,
      angle: nil,
      rotation: nil,
      color: 0xffffff,
      alpha: 255,
    }.freeze

    PARTICLE_OPTIONS = %i[
      scale
      scale_change
      scale_min
      scale_max
      scale_inflection
      angle
      rotation
      color
      alpha
      alpha_change
      alpha_min
      alpha_max
      alpha_inflection
    ].freeze

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
          x = @options[:area] ? @x + rand * @options[:area].x : @x + @options[:spread] * (rand - 0.5)
          y = @options[:area] ? @y + rand * @options[:area].y : @y + @options[:spread] * (rand - 0.5)
          @particles << Particle.new(x:,
                                     y:,
                                     duration: @options[:duration],
                                     shape: @options[:shape],
                                     img: @options[:img],
                                     **@options.slice(*PARTICLE_OPTIONS))
        end
        set_emission_time
        @timer = 0
      end
    end

    def draw(map = nil, z_index = 0)
      @particles.each do |particle|
        particle.draw(map, z_index)
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
        @elapsed_time = 0

        @angle = @options[:angle]
        init_variable_property(:scale)
        init_variable_property(:alpha)
      end

      def init_variable_property(name)
        ivar_name = "@#{name}".to_sym
        case @options["#{name}_change".to_sym]
        when :grow, :alternate
          instance_variable_set(ivar_name, @options["#{name}_min".to_sym])
        when :shrink
          instance_variable_set(ivar_name, @options["#{name}_max".to_sym])
        else
          instance_variable_set(ivar_name, @options[name.to_sym])
        end
      end

      def update_variable_property(name)
        ivar_name = "@#{name}".to_sym
        min = @options["#{name}_min".to_sym]
        max = @options["#{name}_max".to_sym]
        case @options["#{name}_change".to_sym]
        when :grow
          instance_variable_set(ivar_name, min + (@elapsed_time.to_f / @duration) * (max - min))
        when :shrink
          instance_variable_set(ivar_name, max - (@elapsed_time.to_f / @duration) * (max - min))
        when :alternate
          inflection_point = ((@options["#{name}_inflection".to_sym] || 0.5) * @duration).round
          if @elapsed_time >= inflection_point
            instance_variable_set(ivar_name, min + (@duration - @elapsed_time).to_f / (@duration - inflection_point) * (max - min))
          else
            instance_variable_set(ivar_name, min + (@elapsed_time.to_f / inflection_point) * (max - min))
          end
        end
      end

      def dead?
        @elapsed_time >= @duration
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

        update_variable_property(:scale) if @options[:scale_change]
        if @options[:alpha_change]
          update_variable_property(:alpha)
          @alpha = @alpha.round
        end

        @elapsed_time += 1
      end

      def draw(map, z_index)
        x = @x - (map&.cam&.x || 0)
        y = @y - (map&.cam&.y || 0)
        color = (@alpha << 24) | @options[:color]
        if @img
          if @angle
            @img.draw_rot(x, y, z_index, @angle, 0.5, 0.5, @scale, @scale, color)
          else
            @img.draw(x - @img.width * @scale * 0.5, y - @img.height * @scale * 0.5, z_index, @scale, @scale, color)
          end
        else
          case @shape
          when :square
            G.window.draw_rect(@x - @scale * 0.5, @y - @scale * 0.5, @scale, @scale, color, z_index)
          end
        end
      end
    end
  end
end
