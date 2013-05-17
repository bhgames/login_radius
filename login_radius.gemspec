# -*- encoding: utf-8 -*-
require File.expand_path('../lib/login_radius/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jordan Prince"]
  gem.email         = ["jordanmprince@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "login_radius"
  gem.require_paths = ["lib"]
  gem.version       = LoginRadius::VERSION

  gem.add_dependency 'test-unit'
	gem.add_dependency 'em-http-request'
	gem.add_dependency 'em-synchrony'
end
