module MiniGL
  # This class provides methods to easily retrieve string translations from
  # text files.
  class Localization
    class << self
      # The list of available languages. These are symbols corresponding to the
      # names of the files in data/text, without the '.txt' extension.
      attr_reader :languages

      # The current language. It's a symbol corresponding to the name of the
      # file in data/text for that language, without the '.txt' extension.
      attr_reader :language

      # Initializes the localization system. If you're using a custom
      # +Res.prefix+, call this _after_ setting it.
      #
      # The localization system will look for files with extension '.txt' in
      # the <code>[Res.prefix]/data/text</code> folder. In each file,
      # each string should be specified in one line, with the following format:
      #
      # <code>identifier    content content content...</code>
      #
      # Use tab characters between the identifier and the text, not white
      # spaces. This makes it easier to make all the texts aligned and is
      # required for the localization system to work. The identifiers will be
      # used as symbols when retrieving strings.
      #
      # The text contents support placeholders, i.e., markers that can be
      # replaced by arguments you pass to +Localization.text+. To specify a
      # placeholder, simply use the '$' character. For example, if your string
      # is:
      #
      # <code>my_string    Values: $ and $</code>
      #
      # the call <code>Localization.text(:my_string, 'test', 10)</code> will
      # result in "Values: test and 10."
      #
      # To include a literal '$'
      # in the text, use '\\$' (without the quotes). Similarly, use '\\\\' to
      # represent a literal backslash, and just '\\' to represent a line break
      # (i.e. a "\\n" in the resulting string).
      def initialize
        @languages = []
        @texts = {}
        files = Dir["#{Res.prefix}text/*.txt"].sort
        files.each do |f|
          lang = f.split('/')[-1].chomp('.txt').to_sym
          @languages << lang
          @texts[lang] = {}
          File.open(f).each do |l|
            parts = l.split("\t")
            @texts[lang][parts[0].to_sym] = parts[-1].chomp
          end
        end

        @language = @languages[0]
      end

      # Sets the current language. +value+ must be a symbol corresponding to
      # the name of a file in data/text, without the '.txt' extension.
      def language=(value)
        raise "Can't set to invalid language #{value}" unless @languages.include?(value)

        @language = value
      end

      # Retrieves the string identified by +id+ in the current language.
      #
      # See +Localization.initialize+ for details on how to use +args+.
      def text(id, *args)
        value = @texts[@language][id] || '<MISSING STRING>'
        args.each do |arg|
          value = value.sub(/(^|[^\\])\$/, "\\1#{arg}")
        end
        value.gsub('\\$', '$').gsub(/\\(.|$)/) { |m| m[1] == '\\' ? '\\' : "\n#{m[1]}" }
      end
    end
  end
end
