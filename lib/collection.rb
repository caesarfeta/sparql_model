require 'sparql_model'
class Collection < SparqlModel

  def initialize( _key=nil )
    @endpoint = "http://localhost:8080/ds"
    @attributes = {
      :name => [ "this:name", ::String, SINGLE, REQUIRED, UNIQUE, KEY ],
      :keywords => [ "this:keywords", ::String, MULTI ],
      :images => [ "this:images", ::String, MULTI ],
      :subcollection => [ "this:subcollection", ::String, MULTI ],
      :float => [ "this:float", ::Float, SINGLE ],
      :int => [ "this:int", ::Integer, SINGLE ]
    }
    super( _key )
  end
  
end
