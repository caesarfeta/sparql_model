require 'test/unit'
require_relative '../lib/image'

class SparqlModelTest < Test::Unit::TestCase
  
  def test_simple
    assert_equal( 2, 1+1 )
  end
  
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
    begin
      img.keywords = 'blah blah blah'
    rescue
      img.add( :keywords, 'blah blah blah' )
      assert_equal( 1, 1 )
    end
  end
  
  def test_fixnum
    img = Image.new( 'check' )
    begin
      img.x_resolution = "123"
    rescue
      img.x_resolution = 123
      assert_equal( ::Fixnum, img.x_resolution.class )
    end
  end
  
  def test_unique
    
  end
  
end