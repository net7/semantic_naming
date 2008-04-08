require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + "/../lib/semantic_naming"
  
# Test the namespace functionality
class PredicateTest < Test::Unit::TestCase
  include N
  def setup
    @uri = "http://www.predicate_shortcut.com/"
  end
  
  # Tests the basic registering of namespaces
  def test_shortcut
    new_pr = Predicate.shortcut(:newpr, @uri)
    assert_equal(new_pr, NEWPR);
    assert_equal(new_pr.to_s, @uri)
    assert_equal(new_pr, URI.new(@uri))
    assert_kind_of(Predicate, new_pr)
    assert_kind_of(Predicate, NEWPR)
    assert_raise(NameError) { Namespace.shortcut(:newpr, @uri) }
  end  
end
