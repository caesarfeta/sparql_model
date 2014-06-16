require 'test/unit'
require_relative '../lib/sparql_quick'

class SparqlQuickTest < Test::Unit::TestCase
  
  # TODO
  def test_count
    prefixes = { :rdf => "<http://www.w3.org/1999/02/22-rdf-syntax-ns#>" }
    sparql = SparqlQuick.new( "http://localhost:8080/ds", prefixes )
    sparql.count([ :s, "rdf:path", :o ])
    assert_equal( 1, 1 )
  end
  
end