lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sparql_model/version'

Gem::Specification.new do |s|
  s.name        = 'sparql_model'
  s.version     = SparqlModel::VERSION
  s.date        = '2014-06-12'
  s.summary     = "SPARQL data models"
  s.description = "Create data model classes with a SPARQL-queryable triplestore back-end."
  s.authors     = [ "Adam Tavares" ]
  s.email       = 'adamtavares@gmail.com'

  s.homepage    = 'http://github.com/caesarfeta/sparql_model'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "sparql-client"
end
