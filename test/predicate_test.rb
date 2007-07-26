require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + "/../lib/semantic_naming"
  
# Test the namespace functionality
class PredicateTest < Test::Unit::TestCase
  # Tests the basic registering of namespaces
  def test_shortcut
    new_pr = N::Predicate.shortcut(:newpr, "http://www.new.com/")
    assert_equal(new_pr, N::NEWPR);
    assert_equal(new_pr.to_s, "http://www.new.com/")
    assert_equal(new_pr, N::URI.new("http://www.new.com/"))
    assert_kind_of(N::Predicate, new_pr)
    assert_kind_of(N::Predicate, N::NEWPR)
    assert_raise(NameError) { N::Namespace.shortcut(:newpr, "http://www.new.com/") }
  end
end
