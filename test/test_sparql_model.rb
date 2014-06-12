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
  
  
end