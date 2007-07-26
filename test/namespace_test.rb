require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + "/../lib/semantic_naming"
  
# Test the namespace functionality
class NamespaceTest < Test::Unit::TestCase
  # Tests the basic registering of namespaces
  def test_shortcut
    new_ns = N::Namespace.shortcut(:newns, "http://www.new.com/")
    assert_equal(new_ns, N::NEWNS);
    assert_equal(new_ns.to_s, "http://www.new.com/")
    assert_equal(new_ns, N::URI.new("http://www.new.com/"))
    assert_kind_of(N::Namespace, new_ns)
    assert_kind_of(N::Namespace, N::NEWNS)
    assert_raise(NameError) { N::Namespace.shortcut(:newns, "http://www.new.com/") }
  end
end
  
