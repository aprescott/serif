require "fileutils"
require "serif"
require "serif/server"

module Serif
  class Commands
    def initialize(argv)
      @argv = argv.dup
    end

    def process
      command = @argv.shift

      case command
      when "-h", "--help", nil
        print_help
        exit 0
      when "generate"
        generate_site
        exit 0
      when "dev"
        initialize_dev_server
      when "new"
        setup_new_site

        puts
        puts "New site created! Generating site for the first time into _site/"
        puts

        generate_site

        puts
        puts "Site generated."
        exit 0
      else
        abort "Unknown command: #{command}"
      end
    end

    def initialize_dev_server
      server = Serif::DevelopmentServer.new(Dir.pwd)
      server.start
    end

    def generate_site
      site = Serif::Site.new(Dir.pwd)

      begin
        site.generate
      rescue Serif::PostConflictError => e
        puts "Error! Unable to generate because there is a conflict."
        puts
        puts "Conflicts at:"
        puts

        site.conflicts.each do |url, ary|
          puts url
          ary.each do |e|
            puts "\t#{e.path}"
          end
        end

        exit 1
      end
    end

    def setup_new_site
      target_dir = Dir.pwd

      if Dir[File.join(target_dir, "*")].length > 0
        abort "Directory is not empty."
      end

      skeleton_dir = File.join(File.dirname(__FILE__), "..", "..", "site_template")

      puts "Creating _posts"
      FileUtils.mkdir(File.join(target_dir, "_posts"))

      Dir.chdir(skeleton_dir) do
        Dir["*"].each do |f|
          puts "Creating #{f}"
          FileUtils.cp_r(f, target_dir, verbose: false)
        end
      end
    end

    def print_help
      puts <<-END_HELP
  USAGE

    serif [-h | --help]
    serif [COMMAND]

  OPTIONS

    -h, --help  Display this help message and exit immediately.

  COMMANDS

    serif generate    Generate the site in the current directory.

    serif new         Create a site skeleton to get started. Will
                      only run if the current directory is empty.

    serif dev         Start a simple dev server on localhost:8000.
                      Serves up the generated static files, but loads
                      some files (like CSS) from source (instead of
                      out of the _site/ directory).

  ENVIRONMENT VARIABLES

    ENV               Set to 'production' if the command is being run
                      as part of serving up a live site.

                          $ ENV=production serif generate

                      This causes the `file_digest` Liquid tag to
                      return a hex digest of the given file's contents.

  EXAMPLES

    $ serif generate

      Generate the site.

  END_HELP
    end
  end
end
