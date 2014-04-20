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
    when "admin"
      initialize_admin_server(Dir.pwd)
    when "generate"
      generate_site(Dir.pwd)
    when "dev"
      initialize_dev_server(Dir.pwd)
    when "new"
      produce_skeleton(Dir.pwd)
    end
  end

  def initialize_admin_server(source_dir)
    # need to cd to the directory before requiring the admin
    # server, because otherwise Dir.pwd won't be right when
    # the admin server class is defined at require time.
    FileUtils.cd(source_dir)
    require "serif/admin_server"

    server = Serif::AdminServer.new(source_dir)
    server.start
  end

  def initialize_dev_server(source_dir)
    FileUtils.cd(source_dir)

    server = Serif::DevelopmentServer.new(source_dir)
    server.start
  end

  def generate_site(source_dir)

    site = Serif::Site.new(source_dir)

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

  def verify_directory(dir)
    unless Dir.exist?(dir)
      puts "No such directory: #{dir}'"
      exit 1
    end
  end

  def produce_skeleton(dir)
    if !Dir[File.join(dir, "*")].empty?
      abort "Directory is not empty."
    end

    FileUtils.cd(File.join(File.dirname(__FILE__), "..", "..", "statics", "skeleton"))
    files = Dir["*"]
    files.each do |f|
      FileUtils.cp_r(f, dir, verbose: true)
    end
    FileUtils.mkdir(File.join(dir, "_posts"))

    generate_site(dir)

    puts
    puts "*** NOTE ***"
    puts
    puts "You should now edit the username and password in _config.yml"
    puts
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

    serif admin       Start the admin server on localhost:4567.

    serif dev         Start a simple dev server on localhost:8000.
                      Serves up the generated static files, but loads
                      some files (like CSS) from source (instead of
                      out of the _site/ directory).

  ENVIRONMENT VARIABLES

    ENV               Set to 'production' if the command is being run
                      as part of serving up a live site.

                          $ ENV=production serif generate

                          $ ENV=production serif admin

                      Note that this by and large doesn't change much,
                      but in future it may provide extra features.

                      The main benefit is that the `file_digest` tag
                      will return a hex digest of the given file's
                      contents only when ENV is set to production.

  EXAMPLES

    $ serif generate

      Generate the site.

    $ serif admin

      Start the admin server on localhost:4567.

  END_HELP
  end
end
end
