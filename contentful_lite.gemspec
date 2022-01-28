lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "contentful_lite/version"

Gem::Specification.new do |spec|
  spec.name          = "contentful_lite"
  spec.version       = ContentfulLite::VERSION
  spec.authors       = ["Gonzalo Munoz", "Daniel Lopez"]
  spec.email         = ["gonzalo.munoz@juul.com", "dlopez@juul.com"]
  spec.summary       = 'Simple replacement of contentful gem'
  spec.homepage      = "https://github.com/JuulLabs-OSS/contentful_lite"

  spec.require_paths = ["lib"]

  spec.add_dependency "http"
  spec.add_dependency "activemodel"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "rubocop"
end
