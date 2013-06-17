# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sp_authentication/version'

Gem::Specification.new do |spec|
  spec.name          = "sp_authentication"
  spec.version       = SpAuthentication::VERSION
  spec.authors       = ["y.fujii"]
  spec.email         = ["ishikurasakura@gmail.com"]
  spec.description   = %q{smartphone authentication}
  spec.summary       = %q{smartphone authentication for Android and iPhone}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'actionpack', '~> 3.0'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
end
