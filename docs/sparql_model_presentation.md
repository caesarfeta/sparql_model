# sparql_model
https://github.com/caesarfeta/sparql_model

## What is it?
It's the SPARQL version of Active Record.
Stores instances of a datamodel in a SPARQL accessible triplestore.

## Why use it?
It makes getting data in and out of a triplestore really easy.

## How to use it?
### Define the model
	mate /usr/local/imgcollect/rails3/app/models/collection.rb
	mate /usr/local/imgcollect/rails3/app/models/image.rb

	[ Explain what's going on... ]

### Use it
	mate /usr/local/imgcollect/rails3/app/controllers/image_controller.rb

#### Inserting values
	[ upload ]
	[ add ] & [ update ]

model.name = "something"
model.add("key","hatred")

#### Retrieving values
	[ full ]

model.all 
	>> retrieve all values with one query for templating.

model.name, model.urn, model.file, model.keyword 
	>> retrieve individual values.

## Use RestTest
So with this simple set-up you can write scripts to update the triplestore using any HTTP client.

ruby/commandline

	mate /usr/local/imgcollect/rails3/app/helpers/rest_test.rb
	mate /usr/local/imgcollect/rails3/app/helpers/application_helper.rb

javascript/browser

	mate /usr/local/imgcollect/rails3/public/js/ImgCollectApi.js

## See it at work for searching
	http://127.0.0.1:3000/ui_api.html
	[ img original des ][ Go! ]
