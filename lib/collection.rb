require 'sparql_model'
class Collection < SparqlModel

  def initialize( _key=nil )
    
    @prefixes = {
      :this => "<http://localhost/sparql_model/collection#>"
    }
    
    @attributes = {
      :name => [ "this:name", ::String, SINGLE, REQUIRED, UNIQUE, KEY ],
      :keywords => [ "this:keywords", ::String, MULTI ],
      :images => [ "this:images", ::String, MULTI ],
      :subcollection => [ "this:subcollection", ::String, MULTI ]
    }
    
    @model = "<urn:sparql_model:collection>"
    @sparql = SparqlQuick.new( "http://localhost:8080/ds", @prefixes )
    super( _key )
    
  end
end
