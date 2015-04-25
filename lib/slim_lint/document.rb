module SlimLint
  # Represents a parsed Slim document and its associated metadata.
  class Document
    # File name given to source code parsed from just a string.
    STRING_SOURCE = '(string)'

    # @return [SlimLint::Configuration] Configuration used to parse template
    attr_reader :config

    # @return [String] Slim template file path
    attr_reader :file

    # @return [SlimLint::Sexp] Sexpression representing the parsed document
    attr_reader :sexp

    # @return [String] original source code
    attr_reader :source

    # @return [Array<String>] original source code as an array of lines
    attr_reader :source_lines

    # Parses the specified Slim code into a {Document}.
    #
    # @param source [String] Slim code to parse
    # @param options [Hash]
    # @option file [String] file name of document that was parsed
    # @raise [Slim::Parser::Error] if there was a problem parsing the document
    def initialize(source, options)
      @config = options[:config]
      @file = options.fetch(:file, STRING_SOURCE)

      process_source(source)
    end

    private

    # @param source [String] Slim code to parse
    # @raise [Slim::Parser::Error] if there was a problem parsing the document
    def process_source(source)
      @source = strip_frontmatter(source)
      @source_lines = @source.split("\n")

      @engine = SlimLint::Engine.new(file: @file)
      @sexp = @engine.call(source)
    end

    # Removes YAML frontmatter
    def strip_frontmatter(source)
      if config['skip_frontmatter'] &&
        source =~ /
          # From the start of the string
          \A
          # First-capture match --- followed by optional whitespace up
          # to a newline then 0 or more chars followed by an optional newline.
          # This matches the --- and the contents of the frontmatter
          (---\s*\n.*?\n?)
          # From the start of the line
          ^
          # Second capture match --- or ... followed by optional whitespace
          # and newline. This matches the closing --- for the frontmatter.
          (---|\.\.\.)\s*$\n?/mx
        source = $POSTMATCH
      end

      source
    end
  end
end
