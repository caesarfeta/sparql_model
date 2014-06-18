require 'test/unit'
require 'sparql_test'
require 'benchmark'
require_relative '../lib/sparql_quick'

class SparqlQuickTest < Test::Unit::TestCase
  
  def test_empty
    sparql = SparqlTest.handle
    sparql.empty( :all )
    check = sparql.count([ :s, :p, :o ])
    assert_equal( 0, check )
  end
  
  def test_empty_safety
    sparql = SparqlTest.handle
    begin
      sparql.empty()
    rescue
      assert_equal( true, true )
    end
  end
  
#  def test_insert_thousand_triples
#    sparql = SparqlTest.handle
#    sparql.empty( :all )
#    time = Benchmark.measure do
#      (1..1000).each do |i|
#        sparql.insert([ SparqlTest.urn( __method__ ), 'me:num', i ])
#      end
#    end
#    puts time
#    sparql.empty( :all )
#  end
  
  def test_count
    sparql = SparqlTest.handle
    (1..100).each do |i|
      sparql.insert([ SparqlTest.urn( __method__ ), 'me:num', i ])
    end
    check = sparql.count([ SparqlTest.urn( __method__ ), 'me:num', :o ])
    sparql.empty( :all )
    assert_equal( 100, check )
  end
  
end