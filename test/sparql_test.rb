class SparqlTest
  def self.handle
    prefixes = { :me => "<http://localhost:8080/sparql_model#>" }
    return SparqlQuick.new( "http://localhost:8080/ds", prefixes )
  end
  def self.urn( _name )
    return "<urn:sparql:test#{ _name }>"
  end
  def self.empty
    sparql = self.handle()
    sparql.empty( :all )
  end
end