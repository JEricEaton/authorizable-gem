$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "authorizable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "authorizable"
  s.version     = Authorizable::VERSION
  s.authors     = ["Robert Starsi"]
  s.email       = ["klevo@klevo.sk"]
  s.homepage    = "http://klevo.sk"
  s.summary     = "Simple authorization, sign in/out."
  s.description = "Simple authorization, sign in/out."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", '4.2.11.3'
  s.add_dependency "bcrypt", '~> 3.1.7'
  s.add_dependency "sass-rails", "~> 5.0"
  s.add_dependency "responders"

  s.add_development_dependency "mysql2", '>= 0.4.0'
  s.add_development_dependency "pry"
  s.add_development_dependency "capybara"
  s.add_development_dependency "timecop"
end
