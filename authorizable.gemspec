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

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "bcrypt-ruby", "~> 3.0.0"
  
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pry"
  s.add_development_dependency "capybara"
  s.add_development_dependency "timecop"
end
