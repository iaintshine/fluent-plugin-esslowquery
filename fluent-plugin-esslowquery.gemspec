Gem::Specification.new do |gem|
  gem.authors       = ["Boguslaw Mista"]
  gem.email         = ["bodziomista@gmail.com"]
  gem.description   = "Fluent parser plugin for Elasticsearch slow query log file."
  gem.summary       = "Fluent parser plugin for Elasticsearch slow query log file."
  gem.homepage      = "https://github.com/iaintshine/fluent-plugin-esslowquery"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fluent-plugin-esslowquery"
  gem.require_paths = ["lib"]
  gem.version       = "1.0.1"
  gem.add_dependency "fluentd", [">= 0.12.0", "< 2"]
end
