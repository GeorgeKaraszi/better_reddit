# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "better_reddit/version"

Gem::Specification.new do |spec|
  spec.name          = "better_reddit"
  spec.version       = BetterReddit::VERSION
  spec.authors       = ["George J Protacio-Karaszi"]
  spec.email         = ["george@hellogeorge.io"]

  spec.summary       = "A complete Reddit API client with all the bells and whistles. But none of the faraday or Net overhead"
  spec.description   = "A complete Reddit API client with all the bells and whistles. But none of the faraday or Net overhead"
  spec.homepage      = "https://github.com/GeorgeKaraszi/better_reddit"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency("http", "~> 4.0")
  spec.add_dependency("oj", "~> 3.0")

  spec.add_development_dependency("rake", "~> 10.0")
  spec.add_development_dependency("rspec", "~> 3.4")
  spec.add_development_dependency("rspec-its", "~> 1.2")
end
