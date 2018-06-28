
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mandarinbank_api/version"

Gem::Specification.new do |spec|
  spec.name          = "mandarinbank_api"
  spec.version       = MandarinbankApi::VERSION
  spec.authors       = ["Tyralion"]
  spec.email         = ["piliaiev@gmail.com"]

  spec.summary       = %q{Simple gem for API mandarinbank.com}
  spec.description   = %q{Simple gem for API mandarinbank.com}
  spec.homepage      = "https://github.com/dancingbytes/mandarinbank_api"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'oj',     '~> 3.6'
  spec.add_dependency 'dotenv-rails', '~> 2.5'

end
