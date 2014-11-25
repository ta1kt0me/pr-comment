# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pr/comment/version'

Gem::Specification.new do |spec|
  spec.name          = "pr-comment"
  spec.version       = Pr::Comment::VERSION
  spec.authors       = ["ta1kt0me"]
  spec.email         = ["p.wadachi@gmail.com"]
  spec.summary       = %q{pr-comment is CLI tool to display pull request comments.}
  spec.description   = %q{execute `prc comment org/Repo pull_request_no`.}
  spec.homepage      = "https://github.com/ta1kt0me/pr-comment"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'thor'
  spec.add_dependency 'octokit'
end
