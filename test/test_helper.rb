require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require "serif"
require "fileutils"
require "pathname"
require "time"
require "date"

def testing_dir(path = nil)
  full_path = File.join(File.dirname(__FILE__), "site_dir")

  path ? File.join(full_path, path) : full_path
end