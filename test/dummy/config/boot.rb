gemfile = File.expand_path('../../../Gemfile', __dir__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler/setup' # Set up gems listed in the Gemfile.
end

$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
