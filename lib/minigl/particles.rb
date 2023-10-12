module MiniGL
  # A particle system.
  class Particles
    # Create a new particle system.
    # Options:
    # - x (Numeric): x-coordinate of the origin of the particle system. If
    #   +source+ is set, it has precedence.
    # - y (Numeric): y-coordinate of the origin of the particle system. If
    #   +source+ is set, it has precedence.
    # - source: if set, must be an object that responds to +x+ and +y+. The
    #   position of the particle system will be updated to <code>(source.x
    #   + source_offset_x, source.y + source_offset_y)</code> on initialization
    #   and every time +update+ is called.
    # - source_offset_x (Numeric): horizontal offset relative to the +source+
    #   where the particle system will be positioned. Default: 0.
    # - source_offset_y (Numeric): vertical offset relative to the +source+
    #   where the particle system will be positioned. Default: 0.
    # - emission_interval (Integer|Range): interval in frames between each
    #   particle emission. It can be a fixed value or a range, in which case
    #   the interval will be a random value within that range (a new value
    #   before each emission). Default: 10.
    # - emission_rate (Integer|Range): how many particles will be emitted at a
    #   time. It can be a fixed value or a range, in which case a random number
    #   of particles in that range will be emitted each time. Default: 1.
    # - duration (Integer): how many frames each particle will live. Default: 30.
    # - shape (Symbol|nil): one of +:square+, +:triangle_up+, or
    #   +:triangle_down+, to emit basic shapes (if the +img+ option is set, it
    #   has precedence). Shape particles don't support rotation. Either this or
    #   +img+ must be set.
    # - img (Gosu::Image|nil): image of the particle, has precedence over
    #   +shape+. Either this or +shape+ must be set.
    # - scale (Numeric): fixed scale of each particle, ignored if +scale_change+
    #   is set to a valid value. Default: 1.
    # - scale_change (Symbol|nil): one of +:grow+, +:shrink+, or +:alternate+,
    #   indicates how the scale of the particle will change over time. +:grow+
    #   will cause the scale to change from +scale_min+ to +scale_max+;
    #   +:shrink+ will cause the scale to change from +scale_max+ to
    #   +scale_min+; +:alternate+ will cause the scale to first go from
    #   +scale_min+ to +scale_max+, in <code>scale_inflection * duration</code>
    #   frames, and then back to +scale_min+ in the remaining frames. All
    #   changes are linear over time.
    # - scale_min (Numeric): minimum scale, to be used together with
    #   +scale_change+. Default: 0.
    # - scale_max (Numeric): maximum scale, to be used together with
    #   +scale_change+. Default: 1.
    # - scale_inflection (Numeric): should be a number between 0 and 1, to be
    #   used with +scale_change+ set to +:alternate+. Default: 0.5.
    # - alpha (Numeric): fixed alpha of each particle, ignored if +alpha_change+
    #   is set to a valid value. Default: 255.
    # - alpha_change, alpha_min, alpha_max, alpha_inflection: behave the same
    #   way as the corresponding properties for +scale+. Default +alpha_max+ is
    #   255.
    # - angle (Numeric|Range|nil): initial rotation angle of each particle in
    #   degrees. Can be a fixed value or a range, in which case the initial
    #   rotation will be a random value within that range. Default: nil (no
    #   rotation).
    # - rotation(Numeric|nil): how much each particle will rotate each frame,
    #   in degrees. Default: nil (no rotation).
    # - speed (Vector|Hash|nil): specifies how the particle will move each
    #   frame. It can be a +Vector+, in which case the particle will move a
    #   fixed amount (corresponding to the +x+ and +y+ values of the vector)
    #   or a +Hash+ with +:x+ and +:y+ keys, in this case the value can be
    #   fixed or a range, for random movement. Default: nil (no movement).
    # - color (Integer): color to tint the particles, in the 0xRRGGBB format.
    #   Default: 0xffffff (white, no tinting).
    # - round_position (Boolean): only draw particles in integer positions.
    #   Default: true.
    def initialize(**options)
      raise "Particles must have either a shape or an image!" if options[:shape].nil? && options[:img].nil?

      @options = DEFAULT_OPTIONS.merge(options)
      @x = (@options[:source]&.x || @options[:x]) + @options[:source_offset_x]
      @y = (@options[:source]&.y || @options[:y]) + @options[:source_offset_y]

      @particles = []
      @emitting = false
    end

    # Starts emitting particles. This returns +self+, so you can create, start,
    # and assign a particle system to a variable like this:
    # <code>@p_system = Particles.new(...).start</code>
    def start
      set_emission_time
      @timer = @emission_time
      @emitting = true
      self
    end

    # Stops emitting new particles. The existing particles will still be kept
    # alive until they hit +duration+ frames.
    def stop
      @emitting = false
    end

    # Changes particle system origin to <code>(x, y)</code>.
    def move_to(x, y)
      @x = x
      @y = y
    end

    # Returns a boolean indicating whether this particle system is currently
    # emitting particles.
    def emitting?
      @emitting
    end

    # Returns the current particle count.
    def count
      @particles.size
    end

    # Updates the particle system. This should be called in the +update+ loop
    # of the game.
    def update
      @particles.each do |particle|
        particle.update
        @particles.delete(particle) if particle.dead?
      end
      return unless @emitting

      if @options[:source]
        @x = @options[:source].x + @options[:source_offset_x]
        @y = @options[:source].y + @options[:source_offset_y]
      end

      @timer += 1
      if @timer >= @emission_time
        count = @options[:emission_rate].is_a?(Range) ? rand(@options[:emission_rate]) : @options[:emission_rate]
        count.times do
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

    # Draws the particles.
    # Parameters:
    # - map (Map|nil): a map whose camera will be used to determine the
    #   position of particles in the screen.
    # - z_index (Integer): z-index to draw the particles. Default: 0.
    def draw(map = nil, z_index = 0)
      @particles.each do |particle|
        particle.draw(map, z_index)
      end
    end

    private

    # :nodoc:
    DEFAULT_OPTIONS = {
      x: 0,
      y: 0,
      source: nil,
      source_offset_x: 0,
      source_offset_y: 0,
      emission_interval: 10,
      emission_rate: 1,
      duration: 30,
      shape: nil,
      img: nil,
      spread: 0,
      scale: 1,
      scale_change: nil,
      scale_min: 0,
      scale_max: 1,
      scale_inflection: 0.5,
      alpha: 255,
      alpha_change: nil,
      alpha_min: 0,
      alpha_max: 255,
      alpha_inflection: 0.5,
      angle: nil,
      rotation: nil,
      speed: nil,
      color: 0xffffff,
      round_position: true,
    }.freeze

    # :nodoc:
    PARTICLE_OPTIONS = %i[
      scale
      scale_change
      scale_min
      scale_max
      scale_inflection
      alpha
      alpha_change
      alpha_min
      alpha_max
      alpha_inflection
      angle
      rotation
      speed
      color
      round_position
    ].freeze

    def set_emission_time # :nodoc:
      interval = @options[:emission_interval]
      @emission_time = interval.is_a?(Range) ? rand(interval) : interval
    end

    class Particle # :nodoc:
      def initialize(x:, y:, duration:, shape: nil, img: nil, **options)
        @x = x
        @y = y
        @duration = duration
        @shape = shape
        @img = img
        @options = DEFAULT_OPTIONS.slice(*PARTICLE_OPTIONS).merge(options)
        @elapsed_time = 0

        if @options[:angle].is_a?(Range)
          @angle = rand(@options[:angle])
        elsif @options[:angle].is_a?(Numeric)
          @angle = @options[:angle]
        end

        if @options[:speed].is_a?(Hash)
          speed_x = @options[:speed][:x].is_a?(Range) ? rand(@options[:speed][:x]) : (@options[:speed][:x] || 0)
          speed_y = @options[:speed][:y].is_a?(Range) ? rand(@options[:speed][:y]) : (@options[:speed][:y] || 0)
          @speed = Vector.new(speed_x, speed_y)
        elsif @options[:speed].is_a?(Vector)
          @speed = @options[:speed]
        end

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
          inflection_point = (@options["#{name}_inflection".to_sym] * @duration).round
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

        if @speed
          @x += @speed.x
          @y += @speed.y
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
        if @options[:round_position]
          x = x.round
          y = y.round
        end
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
          when :triangle_up
            G.window.draw_triangle(@x - @scale * 0.5, @y + @scale * 0.433, color,
                                   @x + @scale * 0.5, @y + @scale * 0.433, color,
                                   @x, @y - @scale * 0.433, color, z_index)
          when :triangle_down
            G.window.draw_triangle(@x - @scale * 0.5, @y - @scale * 0.433, color,
                                   @x + @scale * 0.5, @y - @scale * 0.433, color,
                                   @x, @y + @scale * 0.433, color, z_index)
          end
        end
      end
    end
  end
end
