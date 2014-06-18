require 'sparql_quick'
class SparqlModel
  
  #-------------------------------------------------------------
  #  Getters
  #-------------------------------------------------------------
  attr_reader :urn
  
  #-------------------------------------------------------------
  #  Configuration constants are more readable than contextless
  #  true & false values
  #-------------------------------------------------------------
  SINGLE = true
  MULTI = false
  
  REQUIRED = true
  OPTIONAL = false
  
  UNIQUE = true
  
  #-------------------------------------------------------------
  #  Used to mark instances
  #-------------------------------------------------------------
  SPAWN = "<http://localhost/sparql_model#spawn>"
  
  def initialize
    @datatype_map = {}
    @prefixes = {}
    @attributes = {}
    @model = nil
    @sparql = nil # SparqlQuick.new( Rails.configuration.sparql_endpoint, @prefixes )
  end
  
  # Create a new instance
  # _values { Hash }
  def create( _values )
    @urn = new_urn()
    required_check( _values )
    change( _values )
    #-------------------------------------------------------------
    #  Mark an instance
    #-------------------------------------------------------------
    @sparql.insert([ @model, SPAWN, @urn ])
    return @urn
  end
  
  # Change values in mass with a hash
  # _values { Hash }
  def change( _values )
    _values.each do | key, value |
      check = single_or_multi( key )
      case check
      when SINGLE
        update( key, value )
      when MULTI
        if value.class == ::Array
          value.each do | subval |
            add( key, subval )
          end
        else
          add( key, value )
        end
      end
    end
  end
  
  # Add a record
  # _key { Symbol }
  # _value { String, Other }
  def add( _key, _value )
    urn?()
    key = _key.to_sym
    attr?( key )
    attr_type( key )
    type_class?( key, _value )
    multi?( key )
    @sparql.insert([ @urn, pred( key ), _value ])
  end
  
  # Delete an attribute
  # _key { Symbol }
  # _value { String, Other }
  def delete( _key, _value=nil )
    urn?()
    key = _key.to_sym
    attr?( key )
    if _value == nil
      @sparql.delete([ @urn, pred( key ), :o ])
      return
    end
    @sparql.delete([ @urn, pred( key ), _value ])
  end
  
  # Get all attributes
  def all
    urn?()
    values = @sparql.select([ @urn, :p, :o ])
    results = {}
    values.each do | value |
      key = uri_to_attr( value[:p] )
      #-------------------------------------------------------------
      #  TODO: Check the value to return
      #-------------------------------------------------------------
      type = @attributes[ key ][1]
      results[ key ] = value[:o].to_s
    end
    results
  end
  
  # _config { String }
  # @return { Hash, Array }
  def list( _config=nil )
    if _full.upcase == 'CONFIG'
      return @attributes
    end
    list = []
    @attributes.each do | _key, _val |
      list.push( _key )
    end
    list.sort()
  end
  
  # Get the number of instances
  # @return { Integer }
  def total
    @sparql.count([ @model, SPAWN, :o ])
  end
  
  # Get instance by id
  # _id { Integer }
  def inst( _id )
    urn = to_urn( _id )
    count = @sparql.count([ urn, :p, :o ])
    if count > 0
      @urn = urn
      return
    end
    raise "Instance #{ urn } could not be found."
  end
  
  # ActiveRecord style trickery
  def method_missing( _key, *_value )
    #-------------------------------------------------------------
    #  Get attribute object key
    #-------------------------------------------------------------
    key = /^[^\=]*/.match( _key ).to_s.to_sym
    #-------------------------------------------------------------
    #  Return current value if no value assigned
    #-------------------------------------------------------------
    value = _value[0]
    update( key, value )
  end
  
  # _uri { RDF::URI, String }
  def uri_to_attr( _uri )
    check = _uri.to_s
    @prefixes.each do | key, val |
      url = val.clip
      if check.include?( url )
        last = check.sub!( url, '' )
        lookup = key.to_s+":"+last
        @attributes.each do | key, val |
          if val[0] == lookup
            return key
          end
        end
      end
    end
    #-------------------------------------------------------------
    #  Something went wrong if you made it this far
    #-------------------------------------------------------------
    raise "Prefix not found #{ check }"
  end
  
  # Check if required values are included
  # _values { Hash }
  def required_check( _values )
    check = []
    @attributes.each do | key, val |
      if val[3] == REQUIRED
        check.push( key )
      end
    end
    missing = []
    check.each do | val |
      if _values.has_key?( val ) == false
        missing.push( val )
      end
    end
    if missing.length > 0
      raise "Required values missing ( #{ missing.join(",") } )"
    end
  end
  
  # Return the right datatype
  def data_value( _key, _value )
    cls = attr_type( _key )
    if cls == ::String
      return _value.to_s
    end
    if cls == ::Integer || cls == ::Fixnum || cls == ::Bignum
      return _value.to_i
    end
    if cls == ::Float
      return _value.to_f
    end
  end
  
  # Update an attribute
  # _key { Symbol }
  # _value { Array, String }
  def update( _key, _value )
    urn?()
    attr?( _key )
    #-------------------------------------------------------------
    #  Get
    #-------------------------------------------------------------
    if _value == nil
      sval = @sparql.value([ @urn, pred( _key ) ])
      cls = sval.class
      #-------------------------------------------------------------
      #  String
      #-------------------------------------------------------------
      if cls == ::String
        return data_value( _key, sval )
      end
      #-------------------------------------------------------------
      #  Array
      #-------------------------------------------------------------
      if cls == ::Array
        out = []
        sval.each do | val |
          out.push( data_value( _key, val ) )
        end
        return out
      end
      #-------------------------------------------------------------
      #  Nothing
      #-------------------------------------------------------------
      return nil
    end
    #-------------------------------------------------------------
    #  Set
    #-------------------------------------------------------------
    attr_type( _key )
    type_class?( _key, _value )
    single?( _key )
    unique?( _key, _value )
    @sparql.update([ @urn, pred( _key ), _value ])
  end
  
  # Does attribute key exist?
  # _key { Symbol } 
  def attr?( _key )
    if @attributes.has_key?( _key ) == false
      raise "Attribute #{ _key } not found."
    end
  end
  
  # Has an attribute type been specified
  # _key { Symbol }
  def attr_type( _key )
    type = @attributes[ _key ][1]
    if type == nil
      raise "Type not specified."
    end
    type
  end
  
  # Make sure a key value pair is unique
  # _key { Symbol }
  # _value { Array, String }
  def unique?( _key, _value )
    if @attributes[ _key ][4] == true
      count = @sparql.count([ :s, pred( _key ), _value ])
      if count > 0
        raise "#{ _key }:#{ _value } pair must be UNIQUE"
      end
    end
  end
  
  # Get the triple predicate
  # _key { Symbol }
  # @return { String }
  def pred( _key )
    p = @attributes[ _key ][0]
    if p == nil
      raise "Triple predicate not specified."
    end
    return p
  end
  
  # _key { Symbol }
  def single?( _key )
    check = single_or_multi( _key )
    if check != SINGLE
      raise "#{ _key } is not a SINGLE attribute. Use add( :#{ _key }, 'value' ) instead."
    end
  end
  
  # _key { Symbol }
  def multi?( _key )
    check = single_or_multi( _key )
    if check != MULTI
      raise "#{ _key } is not a MULTI attribute."
    end
  end
  
  # Make sure URN is defined
  def urn?
    if @urn == nil
      raise "Error @URN is null"
    end
  end
  
  # _key { Symbol }
  def single_or_multi( _key )
    @attributes[ _key ][2]
  end
  
  # _type { Symbol }
  # _value { String, Other }
  def type_class?( _key, _value )
    type = @attributes[ _key ][1]
    check = _value.class
    if check != type
      if type == ::Integer && _value.integer?
        return
      end
      raise "Type mismatch: \"#{ check }\" passed but  \"#{ type }\" is needed."
    end
  end
  
  # Get a new URN
  # @return { String }
  def new_urn
    index = @sparql.next_index([ @model, SPAWN ])
    to_urn( index )
  end
  
  # Turn an index to a new URN
  # _i { Integer }
  # @return { String }
  def to_urn( _i )
    @model.clone.insert( -2, ".#{ _i }" )
  end
end