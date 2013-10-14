# -*- encoding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/lib')
Gem::Specification.new do |gem|
  gem.authors       = ["Bryan Berry"]
  gem.email         = ["bryan.berry@gmail.com"]
  gem.description   = %q{Monkey patches Chef to allow rewinding and unwinding of existing resources}
  gem.summary       = %q{Monkey patches Chef to allow rewinding and unwinding of existing resources}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "chef-rewind"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.7"
end
