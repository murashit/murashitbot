# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'murashitbot/version'

Gem::Specification.new do |gem|
  gem.name          = "murashitbot"
  gem.version       = Murashitbot::VERSION
  gem.authors       = ["murashit"]
  gem.email         = ["upturnpikepointandplace@gmail.com"]
  gem.summary       = "@murashittest"
  gem.description   = "a Marcov-Chain Twitter Bot like @murashittest"
  gem.homepage      = "http://murashit.net/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>=1.9.2'

  gem.add_runtime_dependency('twitter', '>=4.0.0')
  gem.add_runtime_dependency('mecab-ruby', '>=0.99')
  gem.add_runtime_dependency('thor', '>=0.15')
  gem.add_runtime_dependency('oauth', '>=0.4.2')

  gem.add_development_dependency('rspec')
end

