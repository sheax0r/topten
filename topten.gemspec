# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'topten/version'

Gem::Specification.new do |spec|
  spec.name          = "topten"
  spec.version       = Topten::VERSION
  spec.authors       = %w'Michael Shea'
  spec.email         = %w'mike.shea@gmail.com'
  spec.summary       = %q{Lists trending hashtags}
  spec.description   = %q{API to return the top ten trending hashtags from twitter in the past 60 seconds.}
  spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w'lib'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'simplecov', '~> 0.9'

end
