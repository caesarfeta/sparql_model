# SparqlModel & SparqlQuick
* SparqlModel - Create data models with a SPARQL-queryable triplestore back-end.
* SparqlQuick - Query a SPARQL endpoint with ease.

# Requirements
* Ruby
* sparql gem
* Any triplestore that implements RDF, and supports the HTTP and SPARQL prototcols.

# Pitch
* Triplestores have become increasingly popular because... 
	* They scale well
		* New types of data can be stored without much fuss.
	* They're extremely flexible
		* Easier to do the unplanned and unexpected
	* Most use HTTP for moving data in and out.

Traditional web-applications use relational databases for persistent storage.

* Relation Databases
	* Popular because...
		* Retrieve data with keys.
			* Reliability
		* Enforce data types.
			* Reliability
		* Familiarirty	
	* Stink because...
		* Less open-ended
		* Requires very good schema design from outset.
			* Hard to modify.
	
SparqlModel was designed to make creating and interacting with datamodels backed by a triplestore extremely easy.

Triplestore datamodels can be created and improved upon faster than with relational database systems.
With a relational database if you wanted to start storing a new cateogry of data you'd have to run an ALTER TABLE statement to create a new column in the right table and then update your model class.
With a triplestore and SparqlModel you just have to add a single configuration line to your model class.

# Install
	git clone http://github.com/caesarfeta/sparql_model
	cd sparql_model
  rake install

# Uninstall
	gem uninstall sparql_model

# Create a data model with SparqlModel
Here's a sample class.

	require 'sparql_model'
	class Image < SparqlModel
	  def initialize( _key=nil )
	    @endpoint = "http://localhost:8080/ds"
	    @prefixes = {
	      :exif => "<http://www.kanzaki.com/ns/exif#>",
	    }
	    #  attribute => [ predicate, variable-type, value-per-predicate, create-required? ]
	    @attributes = {
	      :path => [ "this:path", ::String, SINGLE, REQUIRED, UNIQUE, KEY ],
	      :keywords => [ "this:keywords", ::String, MULTI ],
	      :image_descrption => [ "exif:imageDescription",  ::String, SINGLE ],
	      :make => [ "exif:make",  ::String, SINGLE ],
	      :model => [ "exif:model", ::String, SINGLE ]
	    }
		super( _key )
	  end
	end

Remember to inherit from SparqlModel

	class Image < SparqlModel

Define an initialize() method

	def initialize( _url=nil )

Define RDF ontology @prefixes

	@prefixes = {
	  :exif => "<http://www.kanzaki.com/ns/exif#>",
	}

Define your model's @attributes

	@attributes = {
	  :path => [ "this:path", ::String, SINGLE, REQUIRED, UNIQUE, KEY ],
	  :keywords => [ "this:keywords", ::String, MULTI ],
	  :image_descrption => [ "exif:imageDescription",  ::String, SINGLE ],
	  :make => [ "exif:make",  ::String, SINGLE ],
	  :model => [ "exif:model", ::String, SINGLE ]
	}

@attributes is a hash of :symbol =&gt; [ Array ] pairs.

Let me explain what's in [ Array ].

* [0] is the RDF-triple predicate value ( :p )
* [1] is the data-type of the RDF-triple object value ( :o )
* [2] some RDF predicates should have only a SINGLE value, others should have MULTI values
* [3] --Optional-- some values are REQUIRED for a new instance to be created
* [4] --Optional-- some SINGLE values must be UNIQUE
* [5] --Optional-- marks the predicate as the KEY used by the get method

So you need an attribute that looks like one of these these...

	:path => [ "this:path", ::String, SINGLE, REQUIRED, UNIQUE, KEY ],
	:id => [ "this:id", ::Fixnum, SINGLE, REQUIRED, UNIQUE, KEY ],

Add this little chunk of code in your initialize function so the parent SparqlModel class runs the get function and configures necessities when you initialize the class.

	super( _key )

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
