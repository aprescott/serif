require "simplecov"
require "bundler/setup"

# if we're running on Travis, use Coveralls, otherwise
# let us generate SimpleCov output as normal.
if ENV["CI"]
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_filter "/test/"
end

# run tests in production mode so that file digests are enabled
ENV["ENV"] = "production"

require "pry"
require "serif"
require "serif/commands"
require "fileutils"
require "pathname"
require "time"
require "date"
require "timecop"
require "turnip/capybara"

Dir[File.join(File.dirname(__FILE__), "support", "*")].each do |f|
  require f
end

Dir[File.join(File.dirname(__FILE__), "acceptance", "macros", "*")].each do |f|
  require f
end

def testing_dir(path = nil)
  full_path = File.join(File.dirname(__FILE__), "site_dir")

  path ? File.join(full_path, path) : full_path
end

def capture_stdout
  begin
    $orig_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.rewind
    return $stdout.string
  ensure
    $stdout = $orig_stdout
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.full_backtrace = true
  end

  # TODO: Stop doing FileUtils.cd at runtime to avoid the need for this.
  config.before :each do
    FileUtils.cd File.expand_path(File.join(__FILE__, "..", ".."))
  end
end

FileUtils.cd testing_dir
require "serif/admin_server"
Capybara.app = Serif::AdminServer::AdminApp
FileUtils.cd File.expand_path(File.join(__FILE__, "..", ".."))
