class TestingSiteGenerationError < StandardError; end

def testing_dir(path = nil)
  full_path = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), "..", "test_source"))

  path = path ? File.join(full_path, path) : full_path

  File.expand_path(path)
end

def capture_stdout
  if ENV["FULL_STDOUT"] == "1"
    yield
  else
    begin
      $orig_stdout = $stdout
      $stdout = StringIO.new
      result = yield
      $stdout.rewind
      $stdout.string

      result
    ensure
      $stdout = $orig_stdout
    end
  end
end

def serif_bin
  root_path = File.expand_path("../../..", __FILE__)
  serif_bin = File.join(root_path, "bin/serif")
end

def generate_site(env: "production")
  root_path = File.expand_path("../../..", __FILE__)

  if ENV["USE_SHELL"] == "no"
    Serif::Commands.class_eval do
      define_method(:exit) do |code|
        if code > 0
          raise TestingSiteGenerationError, "failed to generate site"
        end
      end
    end

    ENV["ENV"] = env
    capture_stdout { Dir.chdir(File.join(root_path, "spec/test_source")) { Serif::Commands.new(["generate"]).process } }
  else
    system("cd #{File.join(root_path, "spec/test_source")} && ENV=#{env} #{serif_bin} generate > /dev/null") || raise(TestingSiteGenerationError, "failed to generate site")
  end
end

def create_new_site(directory)
  if ENV["USE_SHELL"] == "no"
    Serif::Commands.class_eval do
      define_method(:exit) do |code|
        if code > 0
          raise TestingSiteGenerationError, "failed to generate site"
        end
      end
    end

    FileUtils.mkdir(directory)

    Dir.chdir(directory) do
      capture_stdout { Serif::Commands.new(["new"]).process }
    end
  else
    system("cd #{File.dirname(directory)} && mkdir #{File.basename(directory)} && cd #{File.basename(directory)} && #{serif_bin} new > /dev/null") || raise(TestingSiteGenerationError, "failed to create new site")
  end
end

def with_file_contents(path, contents, removal_path: nil, &block)
  raise "refusing to modify existing file: #{path}" if File.exist?(path)

  begin
    File.open(path, "w") do |f|
      f.puts contents
    end

    block.call
  ensure
    FileUtils.rm(removal_path || path)
  end
end
