lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "contentful_lite/version"

Gem::Specification.new do |spec|
  spec.name          = "contentful-lite"
  spec.version       = ContentfulLite::VERSION
  spec.authors       = ["Gonzalo Munoz", "Daniel Lopez"]
  spec.email         = ["gonzalo.munoz@juul.com", "dlopez@juul.com"]
  spec.summary       = 'Simple replacement of contentful gem'
  spec.homepage      = "https://github.com/JuulLabs/contentful-lite"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  end

  spec.require_paths = ["lib"]
end
