# SparqlModel & SparqlQuick

SparqlModel - Create data model classes with a SPARQL-queryable triplestore back-end.
SparqlQuick - Query a SPARQL endpoint with ease.

* Should work with any SPARQL endpoint
* Easy to use

# Create a data model with SparqlModel
Here's a sample.

	class Image < SparqlModel
	  
	  # Constructor...
	  # _url { String } The URL to the image
	  def initialize( _url=nil )
	    
	    @prefixes = {
	      :rdf => "<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
	      :exif => "<http://www.kanzaki.com/ns/exif#>"
	    }
	    
	    #  attribute => [ predicate, variable-type, value-per-predicate, create-required? ]
	    @attributes = {
	      :path => [ "rdf:path", ::String, SINGLE, REQUIRED ],
	      :keywords => [ "rdf:keywords", ::String, MULTI ],
	      :x_resolution => [ "exif:xResolution", ::String, SINGLE ],
	      :y_resolution => [ "exif:yResolution", ::String, SINGLE ]
	    }
	    
	    @template = "<urn:image.%>"
	    @sparql = SparqlQuick.new( "http://localhost:8080/ds", @prefixes )
	    
	    #-------------------------------------------------------------
	    #  If image URL is supplied get it
	    #-------------------------------------------------------------
	    if _url != nil
	      get( _url )
	    end
	    
	  end
	  
	  # _url { String } The URL to the image
	  def get( _url )
	    results = @sparql.select([ :s, pred( :path ), _url ])
	    if results.length == 0
	      raise "Record could not be found for #{ url }"
	    end
	    @urn = "<"+results[0][:s].to_s+">"
	  end
	    
	end

Remember to inherit from SparqlModel

	class Image < SparqlModel

Define an initialize() method

	def initialize( _url=nil )

Define RDF ontology @prefixes

	@prefixes = {
	  :rdf => "<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
	  :exif => "<http://www.kanzaki.com/ns/exif#>"
	}

Define your model's @attributes

    @attributes = {
      :path => [ "rdf:path", ::String, SINGLE, REQUIRED ],
      :keywords => [ "rdf:keywords", ::String, MULTI ],
      :x_resolution => [ "exif:xResolution", ::String, SINGLE ],
      :y_resolution => [ "exif:yResolution", ::String, SINGLE ]
    }

@attributes is a hash of :symbol =&gt; [ Array ] pairs.

Let me explain what's in [ Array ].

* [0] is the RDF-triple predicate value ( :p )
* [1] is the data-type of the RDF-triple object value ( :o )
* [2] some RDF predicates should have only a SINGLE value, others should have MULTI values
* [3] --Optional-- some values are REQUIRED for a new instance to be created

Define the URN @template for your RDF-triple subject value ( :s ).

	@template = "<urn:image.%>"

The % sign will be replaced by an integer id value, &lt;urn:image.1&gt;, &lt;urn:image.2&gt;, etc., everytime a new instance of your model is created.

Create a connection to your @sparql endpoint with a SparqlQuick instance.
Remember to pass your @prefixes to the SparqlQuick constructor.

	@sparql = SparqlQuick.new( "http://localhost:8080/ds", @prefixes )

Create a get() method which you will use to grab the instance RDF subject @urn.
The example below takes a URL and sets the subject @urn

	  # _url { String } The URL to the image
	  def get( _url )
	    results = @sparql.select([ :s, pred( :path ), _url ])
	    if results.length == 0
	      raise "Record could not be found for #{ url }"
	    end
	    @urn = "<"+results[0][:s].to_s+">"
	  end

I add this little chunk of code in my initialize function so I can run my get function if I pass a URL when I initialize the class.

	if _url != nil
	  get( _url )
	end

Now you have a data model.
Let's do something with it.

# Using your data model
Get an instance

	img = Image.new

Create a new record

	img.create({ 
		:path => "http://localhost/images/photo.jpg", 
		:keywords => [ "vacation", "2014", "canyon" ], 
		:x_resolution => 4098,
		:y_resolution => 2048
	})

Retrieve values

	img.path
	img.keywords

Change SINGLE values

	img.x_resolution = 4096

Add MULTI values
Delete values

Values are changed on the fly.

# To run the test suite.
## Install fuseki SPARQL server
	cd /usr/local/imgcollect
	curl -O http://www.interior-dsgn.com/apache//jena/binaries/jena-fuseki-1.0.1-distribution.tar.gz
	tar xvzf jena-fuseki-1.0.1-distribution.tar.gz
	ln -s jena-fuseki-1.0.1 fuseki
	chmod +x fuseki/fuseki-server fuseki/s-**

## Start the fuseki server on port 8080
	cd fuseki
	./fuseki-server --update --mem --port=8080 /ds &
	echo $! > fuseki.pid
