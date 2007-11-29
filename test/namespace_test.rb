require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + "/../lib/semantic_naming"
  
# Test the namespace functionality
class NamespaceTest < Test::Unit::TestCase
  # Tests the basic registering of namespaces
  def test_shortcut
    new_ns = N::Namespace.shortcut(:ns_short, "http://www.ns_short.com/")
    assert_equal(new_ns, N::NS_SHORT);
    assert_equal(new_ns.to_s, "http://www.ns_short.com/")
    assert_equal(new_ns, N::URI.new("http://www.ns_short.com/"))
    assert_kind_of(N::Namespace, new_ns)
    assert_kind_of(N::Namespace, N::NS_SHORT)
    assert_raise(NameError) { N::Namespace.shortcut(:ns_short, "http://www.ns_short.com/") }
  end
  
  # Test if the "shortcuts" method works correctly for namespaces
  def test_shortcuts
    N::Namespace.shortcut(:at_least_one_ns, "http://atleast_namespace.com/")
    N::URI.shortcut(:another_one_outside_uri, "http://anotherone_uri.com/")
    assert(N::Namespace.shortcuts.size > 0, "There should be at least one namespace shortcut")
    assert(!N::Namespace.shortcuts.include?(:another_one_outside))
  end
  
  # Test the array-type accessor
  def test_array_type_access
    new_ns = N::Namespace.shortcut(:ns_array_test, "http://www.ns_array_test.com/")
    assert_equal(new_ns, N::Namespace[:ns_array_test])
  end
  
  # Test the array-type accessor if the superclass is excluded
  def test_array_type_access_super
    new_ns = N::URI.shortcut(:ns_array_test_s, "http://www.ns_array_test_super.com/")
    assert_equal(nil, N::Namespace[:ns_array_test_s])
  end
  
  # Test the array-type accessor if sibling classes are excluded
  def test_array_type_access_sibling
    new_ns = N::URI.shortcut(:ns_array_test_sib, "http://www.ns_array_test_sibling.com/")
    assert_equal(nil, N::Namespace[:ns_array_test_sib])
  end
end
  
