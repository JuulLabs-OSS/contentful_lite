lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "contentful_lite/version"

Gem::Specification.new do |spec|
  spec.name          = "contentful_lite"
  spec.version       = ContentfulLite::VERSION
  spec.authors       = ["Gonzalo Munoz", "Daniel Lopez"]
  spec.email         = ["gonzalo.munoz@juul.com", "dlopez@juul.com"]
  spec.summary       = 'Simple and lite replacement client for Contentful\'s Content Delivery API'
  spec.homepage      = "https://github.com/JuulLabs-OSS/contentful_lite"
  spec.license       = 'MIT'

  spec.files         = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.test_files    = Dir["spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "http", '~> 4.3'
  spec.add_dependency "activemodel", '~> 6.0', '>= 6.0.2.1'

  spec.add_development_dependency "rspec", '~> 3.9'
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "rubocop"
end
