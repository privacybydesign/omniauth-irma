$:.push File.expand_path("lib", __dir__)

require "omniauth/irma/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-irma"
  spec.version       = Omniauth::Irma::VERSION
  spec.authors       = ["Sietse Ringers"]
  spec.email         = ["mail@sietseringers.net"]

  spec.summary       = %q{IRMA strategy for OmniAuth}
  spec.homepage      = "https://irma.app/docs"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
end
