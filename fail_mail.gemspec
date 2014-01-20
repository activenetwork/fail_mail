# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fail_mail/version'

Gem::Specification.new do |spec|
  spec.name          = "fail_mail"
  spec.version       = FailMail::VERSION
  s.authors          = ['Adam Zaninovich']
  s.email            = ['adam.zaninovich@gmail.com']
  s.homepage         = ""
  s.summary          = %q{Lyris is an enterprise email service. FailMail makes it easy for Ruby to talk to Lyris's API.}
  s.description      = %q{Lyris is an enterprise email service. FailMail makes it easy for Ruby to talk to Lyris's API.}

  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "savon", "~> 2.2.0"
end
