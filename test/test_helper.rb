require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

# run tests in production mode so that file digests are enabled
ENV["ENV"] = "production"

require "serif"
require "fileutils"
require "pathname"
require "time"
require "date"
require "timecop"

def testing_dir(path = nil)
  full_path = File.join(File.dirname(__FILE__), "site_dir")

  path ? File.join(full_path, path) : full_path
end