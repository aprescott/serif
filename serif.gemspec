Gem::Specification.new do |s|
  s.name         = "serif"
  s.version      = "0.6"
  s.authors      = ["Adam Prescott"]
  s.email        = ["adam@aprescott.com"]
  s.homepage     = "https://github.com/aprescott/serif"
  s.summary      = "Static site generator and markdown-based blogging with an optional admin interface complete with drag-and-drop image uploading."
  s.description  = "Serif is a static site generator and blogging system powered by markdown files and an optional admin interface complete with drag-and-drop image uploading."
  s.files        = Dir["{lib/**/*,statics/**/*,bin/*,test/**/*}"] + %w[serif.gemspec rakefile LICENSE Gemfile Gemfile.lock README.md]
  s.require_path = "lib"
  s.bindir       = "bin"
  s.executables  = "serif"
  s.test_files   = Dir["test/*"]
  s.required_ruby_version = ">= 1.9.3"
  s.licenses = ["MIT"]

  [
    "rack", "~> 1.0",
    "kramdown", "~> 1.3",
    "rubypants", nil,
    "rouge", "~> 0.3.2",
    "sinatra", "~> 1.3",
    "redhead", "~> 0.0.8",
    "liquid", "~> 3.0",
    "reverse_markdown", nil,
    "nokogiri", "~> 1.5",
    "timeout_cache"
  ].each_slice(2) do |name, version|
    s.add_runtime_dependency(name, version)
  end

  s.add_development_dependency("rake", "~> 0.9")
  s.add_development_dependency("rspec", "~> 2.5")
  s.add_development_dependency("simplecov", "~> 0.7")
  s.add_development_dependency("timecop", "~> 0.6.1")
  s.add_development_dependency("rdoc", "~> 4.0.0")
  s.add_development_dependency("coveralls")
  s.add_development_dependency("turnip")
  s.add_development_dependency("capybara")
  s.add_development_dependency("poltergeist")
  s.add_development_dependency("pry")
end
