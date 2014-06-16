require 'test/unit'
require_relative '../lib/image'

class SparqlModelTest < Test::Unit::TestCase
  
  def test_create
    img = Image.new
    img.create({ :path => 'check' })
    assert_equal( 'check', img.path )
  end
  
  def test_new_get
    img = Image.new( 'check' )
    assert_equal( 'check', img.path )
  end
  
  def test_multi_assignment_error
    img = Image.new( 'check' )
    check = false
    begin
      img.keywords = 'blah blah blah'
    rescue
      img.add( :keywords, 'blah blah blah' )
      check = true
    end
    assert_equal( true, check )
  end
  
  def test_fixnum
    img = Image.new( 'check' )
    check = false
    begin
      img.x_resolution = "123"
    rescue
      img.x_resolution = 123
      check = img.x_resolution.class
    end
    assert_equal( ::Fixnum, check )
  end
  
  def test_unique
    img = Image.new
    img.create({ :path => 'test_unique' })
    check = false
    begin
      img.create({ :path => 'test_unique' })
    rescue
      check = true
    end
    assert_equal( true, check )
  end
  
  def test_add_single?
    img = Image.new
    img.create({ :path => 'test_add_single?--1' })
    img.create({ :path => 'test_add_single?--2' })
    check = false
    begin
      img.add( :path, 'test_add_single?--1' )
    rescue
      check = true
    end
    assert_equal( true, check )
  end
  
end