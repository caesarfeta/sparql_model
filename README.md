# SparqlModel & SparqlQuick
* SparqlModel - Create data models with a SPARQL-queryable triplestore back-end.
* SparqlQuick - Query a SPARQL endpoint with ease.



# Install
	git clone http://github.com/caesarfeta/sparql_model
	cd sparql_model
	gem build sparql_model.gemspec
	gem install sparql_model-0.0.0.gem



# Uninstall
	gem uninstall sparql_model



# Create a data model with SparqlModel
Here's a sample class.

	class Image < SparqlModel
	  
	  # Constructor...
	  # _url { String } The URL to the image
	  def initialize( _url=nil )
	    
	    @prefixes = {
	    :exif => "<http://www.kanzaki.com/ns/exif#>",
	      :this => "<http://localhost/sparql_model/image#>"
	    }
	    
	    #  attribute => [ predicate, variable-type, value-per-predicate, create-required? ]
	    @attributes = {
	      :path => [ "this:path", ::String, SINGLE, REQUIRED, UNIQUE ],
	      :keywords => [ "this:keywords", ::String, MULTI ],
	      :x_resolution => [ "exif:xResolution", ::String, SINGLE ],
	      :y_resolution => [ "exif:yResolution", ::String, SINGLE ]
	    }
	    
	    @model = "<urn:image>"
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
* [4] --Optional-- some SINGLE values must be UNIQUE

Define the @model name

	@model = "<urn:image>"

@model becomes the template for each instances RDF-triple subject value ( :s ).

	<urn:image.1>
	<urn:image.2>

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
Load your model class

	load 'image.rb'

Get an instance

	img = Image.new

Create a new record

	img.create({ :path => "http://localhost/images/photo.jpg", :keywords => [ "vacation", "2014", "canyon" ] })

or get an existing record

	img = Image.new( "http://localhost/images/photo.jpg" )
	img.get( "http://localhost/images/photo.jpg" )
	img.inst(1)

Retrieve values

	img.path
	img.keywords

Add or change a SINGLE value

	img.x_resolution = 4096

Add MULTI values

	img.add( :keywords, "arizona" )

Delete a MULTI value

	img.delete( :keywords, "arizona" )

Delete a SINGLE value or all MULTI values

	img.delete( :keywords )

Destroy the instance.  Remove any triple where instance is a subject or an object.

	img.destroy()

If you're running your code on the test fuseki server, you can [ see the RDF triples change on the fly.]( http://localhost:8080/ds/query?query=select+%3Fs+%3Fp+%3Fo%0D%0Awhere+%7B+%3Fs+%3Fp+%3Fo+%7D&output=text&stylesheet= )



# Using multiple classes together
Load your classes

	load 'collection.rb'
	load 'image.rb'

Create a collection instance

	col = Collection.new

Create a collection

	col.create({ :name => "Collection Test" })

Create some image records

	img = Image.new
	img.create({ :path => "http://localhost/images/photo.jpg", :keywords => [ "vacation", "2014", "canyon" ] })
	img.create({ :path => "http://localhost/images/photo2.jpg", :keywords => [ "vacation", "2014", "canyon" ] })

Add an image to the collection

	col.add( :images, img.get('http://localhost/images/photo.jpg') )
	col.add( :images, img.get('http://localhost/images/photo2.jpg') )




# To run the test suite.
## Install fuseki SPARQL server
	cd /usr/local/sparql_model
	curl -O http://apache.mesi.com.ar//jena/binaries/jena-fuseki-1.0.2-distribution.tar.gz
	tar xvzf jena-fuseki-1.0.2-distribution.tar.gz
	ln -s jena-fuseki-1.0.2 fuseki
	chmod +x fuseki/fuseki-server fuseki/s-**

## Start the fuseki server on port 8080
	cd fuseki
	./fuseki-server --update --mem --port=8080 /ds &
	echo $! > fuseki.pid

## Run the tests
	cd /usr/local/sparql_model
	rake



# Quickie development environment
	cd /usr/local/sparql_model/lib
	irb -I .
	load 'image.rb'

Make a change?

	exec($0)
	load "image.rb"

Want to track down where dependencies are located?

	mate `gem which sparql`
	[editor] `gem which [gem]`
