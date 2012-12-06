# -*- encoding: utf-8 -*-
require File.expand_path('../lib/masyo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Takatoshi Matsumoto"]
  gem.email         = ["toqoz403@gmail.com"]
  gem.description   = "simple tcp proxy server written in ruby"
  gem.summary       = "masyo"
  gem.homepage      = "https://github.com/ToQoz/Masyo"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "masyo"
  gem.require_paths = ["lib"]
  gem.version       = Masyo::VERSION

  gem.add_dependency "slop"
end
