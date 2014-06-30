require 'sparql_model'
class Collection < SparqlModel

  def initialize( _key=nil )
    @endpoint = "http://localhost:8080/ds"
    @model = "<urn:sparql_model:collection>"
    @prefixes = {
      :this => "<http://localhost/sparql_model/collection#>"
    }
    @attributes = {
      :name => [ "this:name", ::String, SINGLE, REQUIRED, UNIQUE, KEY ],
      :keywords => [ "this:keywords", ::String, MULTI ],
      :images => [ "this:images", ::String, MULTI ],
      :subcollection => [ "this:subcollection", ::String, MULTI ]
    }
    super( _key )
  end
  
end
