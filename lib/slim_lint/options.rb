require 'optparse'

module SlimLint
  # Handles option parsing for the command line application.
  class Options
    # Parses command line options into an options hash.
    #
    # @param args [Array<String>] arguments passed via the command line
    # @return [Hash] parsed options
    def parse(args)
      @options = {}

      OptionParser.new do |parser|
        parser.banner = "Usage: #{APP_NAME} [options] [file1, file2, ...]"

        add_linter_options parser
        add_file_options parser
        add_info_options parser
      end.parse!(args)

      # Any remaining arguments are assumed to be files
      @options[:files] = args

      @options
    rescue OptionParser::InvalidOption => ex
      raise Exceptions::InvalidCLIOption,
            ex.message,
            ex.backtrace
    end

    private

    # Register linter-related flags.
    def add_linter_options(parser)
      parser.on('-e', '--exclude file,...', Array,
                'List of file names to exclude') do |files|
        @options[:excluded_files] = files
      end

      parser.on('-i', '--include-linter linter,...', Array,
                'Specify which linters you want to run') do |linters|
        @options[:included_linters] = linters
      end

      parser.on('-x', '--exclude-linter linter,...', Array,
                "Specify which linters you don't want to run") do |linters|
        @options[:excluded_linters] = linters
      end

      parser.on('-r', '--reporter reporter', String,
                'Specify which reporter you want to use to generate the output') do |reporter|
        @options[:reporter] = SlimLint::Reporter.const_get("#{reporter.capitalize}Reporter")
      end
    end

    # Register file-related flags.
    def add_file_options(parser)
      parser.on('-c', '--config config-file', String,
                'Specify which configuration file you want to use') do |conf_file|
        @options[:config_file] = conf_file
      end

      parser.on('-e', '--exclude file,...', Array,
                'List of file names to exclude') do |files|
        @options[:excluded_files] = files
      end
    end

    # Register informational flags.
    def add_info_options(parser)
      parser.on('--show-linters', 'Display available linters') do
        @options[:show_linters] = true
      end

      parser.on('--show-reporters', 'Display available reporters') do
        @options[:show_reporters] = true
      end

      parser.on('--[no-]color', 'Force output to be colorized') do |color|
        @options[:color] = color
      end

      parser.on_tail('-h', '--help', 'Display help documentation') do
        @options[:help] = parser.help
      end

      parser.on_tail('-v', '--version', 'Display version') do
        @options[:version] = true
      end
    end
  end
end
