# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'silent_fetcher/version'

Gem::Specification.new do |spec|
  spec.name          = "silent_fetcher"
  spec.version       = SilentFetcher::VERSION
  spec.authors       = ["Takashi Chiba"]
  spec.email         = ["contact@takashi.me"]
  spec.summary       = %q{Fetch response silently}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', '~> 0.13'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'feedjira', '~> 1.3'

  spec.add_development_dependency 'minitest', '~> 5.3.3'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'webmock', '~> 1.18'
end
