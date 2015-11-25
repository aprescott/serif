Gem::Specification.new do |s|
  s.name         = "serif"
  s.version      = "0.6"
  s.authors      = ["Adam Prescott"]
  s.email        = ["adam@aprescott.com"]
  s.homepage     = "https://github.com/aprescott/serif"
  s.summary      = "Static site generator and markdown-based blogging."
  s.description  = "Serif is a static site generator and blogging system powered by markdown files."
  s.files        = Dir["{lib/**/*,site_template/**/*,bin/*,spec/**/*}"] + %w[serif.gemspec rakefile LICENSE Gemfile Gemfile.lock README.md]
  s.require_path = "lib"
  s.bindir       = "bin"
  s.executables  = "serif"
  s.test_files   = Dir["spec/*"]
  s.required_ruby_version = ">= 2.1.0"
  s.licenses = ["MIT"]

  s.add_runtime_dependency "kramdown", ">= 1.9.0"
  s.add_runtime_dependency "rubypants"
  s.add_runtime_dependency "rouge", ">= 1.10.0"
  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "redhead"
  s.add_runtime_dependency "liquid", "~> 2.0"

  s.add_development_dependency "nokogiri"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "timecop"

  s.add_development_dependency "bundler-audit"
end
