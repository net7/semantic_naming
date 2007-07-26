require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + "/../lib/semantic_naming"
  
# Test the uri class
class TypeTest < Test::Unit::TestCase
  
  # Tests the basic registering of namespaces
  def test_shortcut
    new_sc = N::SourceClass.shortcut(:newsc, "http://www.new.com/")
    assert_equal(new_sc, N::NEWSC);
    assert_equal(new_sc.to_s, "http://www.new.com/")
    assert_equal(new_sc, N::URI.new("http://www.new.com/"))
    assert_kind_of(N::SourceClass, new_sc)
    assert_kind_of(N::SourceClass, N::NEWSC)
    assert_raise(NameError) { N::Namespace.shortcut(:newsc, "http://www.new.com/") }
  end
end
