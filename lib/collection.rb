require 'sparql_model'
class Collection < SparqlModel
  
  # Constructor...
  # _url { String } The URL to the image
  def initialize( _url=nil )
    
    @prefixes = {
      :this => "<http://localhost/sparql_model/collection#>"
    }
    
    #  attribute => [ predicate, variable-type, value-per-predicate, create-required?, unique-value ]
    @attributes = {
      :name => [ "this:name", ::String, SINGLE, REQUIRED, UNIQUE ],
      :keywords => [ "this:keywords", ::String, MULTI ],
      :images => [ "this:images", ::String, MULTI ],
      :subcollection => [ "this:subcollection", ::String, MULTI ]
    }
    
    @model = "<urn:sparql_model:collection>"
    @sparql = SparqlQuick.new( "http://localhost:8080/ds", @prefixes )
    
    #-------------------------------------------------------------
    #  If image URL is supplied get it
    #-------------------------------------------------------------
    if _url != nil
      get( _url )
    end
    
  end
  
  # _name { String } The URL to the image
  def get( _name )
    results = @sparql.select([ :s, pred( :name ), _name ])
    if results.length == 0
      raise "Instance could not be found, :name => #{ _name }"
    end
    @urn = "<"+results[0][:s].to_s+">"
  end
    
end
