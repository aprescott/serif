Gem::Specification.new do |s|
  s.name         = "serif"
  s.version      = "0.3.2"
  s.authors      = ["Adam Prescott"]
  s.email        = ["adam@aprescott.com"]
  s.homepage     = "https://github.com/aprescott/serif"
  s.summary      = "Markdown-powered blogging with an optional admin interface with drag-and-drop image uploading."
  s.description  = "Serif is a blogging system powered by markdown files and an optional admin interface complete with drag-and-drop image uploading."
  s.files        = Dir["{lib/**/*,statics/**/*,bin/*,test/**/*}"] + %w[serif.gemspec rakefile LICENSE Gemfile Gemfile.lock README.md]
  s.require_path = "lib"
  s.bindir       = "bin"
  s.executables  = "serif"
  s.test_files   = Dir["test/*"]

  [
    "rack", "~> 1.0",
    "rack-rewrite", "~> 1.3.0",
    "redcarpet", "~> 2.2",
    "pygments.rb", "~> 0.3",
    "sinatra", "~> 1.3",
    "redhead", "~> 0.0.8",
    "liquid", "~> 2.4",
    "slop", "~> 3.3",
    "timeout_cache"
  ].each_slice(2) do |name, version|
    s.add_runtime_dependency(name, version)
  end

  s.add_development_dependency("rake", "~> 0.9")
  s.add_development_dependency("rspec", "~> 2.5")
  s.add_development_dependency("simplecov", "~> 0.7")
  s.add_development_dependency("timecop", "~> 0.5.5")
end
