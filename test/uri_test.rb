require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + "/../lib/semantic_naming"
  
# Test the uri class
class URITest < Test::Unit::TestCase
  
  @@local_domain = "http://www.samplething.com/"
  if(!N.const_defined?(:LOCAL))
    N::Namespace.shortcut(:local, @@local_domain)
  end
  
  # Basic test for uri class
  def test_uri
    uri_string = "http://foobar.com/xyz/"
    uri = N::URI.new(uri_string)
    assert_equal(uri_string, uri.to_s)
  end
  
  # Test local and remote checks
  def test_local_remote
    local_string = @@local_domain + "/myid"
    remote_string = "http://www.remote.com/something"
    
    
    domain = N::URI.new(@@local_domain)
    local = N::URI.new(local_string)
    remote = N::URI.new(remote_string)
    
    assert(local.local?)
    assert(!local.remote?)
    assert(remote.remote?)
    assert(!remote.local?)
    assert(domain.local?)
  end
  
  # Tests the equality operator
  def test_equality
   uri_string = "http://foobar.com/xyz/"
   uri = N::URI.new(uri_string)
   uri_2 = N::URI.new(uri_string)
   uri_other = N::URI.new("http://otheruri.com/")
   
   assert_equal(uri, uri_string)
   assert_equal(uri, uri)
   assert_equal(uri, uri_2)
   assert_not_equal("http://something.org", uri)
   assert_not_equal(uri, uri_other)
   assert_not_equal(uri, Hash.new)
  end
  
  # Tests the domain_of operation
  def test_domain_of
    local_string = @@local_domain + "/myid"
    remote_string = "http://www.remote.com/something"
    
    local_domain = N::URI.new(@@local_domain)
    local = N::URI.new(local_string)
    remote = N::URI.new(remote_string)
    
    assert(local.domain_of?(local))
    assert(local.domain_of?(local_string))
    assert(local_domain.domain_of?(local))
    assert(local_domain.domain_of?(local_string))
    
    assert(!local.domain_of?(local_domain))
    assert(!local.domain_of?(remote))
    assert(!local.domain_of?(remote_string))
    assert(!remote.domain_of?(local))
  end
  
  # Test the add operator
  def test_add
    uri_string = "http://foobar.com/xyz/"
    uri = N::URI.new(uri_string)
    assert_equal(N::URI.new(uri_string + "add"), uri + "add")
    assert_equal(N::URI.new(uri_string +  "add"), uri + N::URI.new("add"))
  end
  
  # Test if builtin methods were overwritten
  def test_builtin_overwrite
    domain = N::URI.new(@@local_domain)
    assert_kind_of(N::URI, domain::type)
    assert_equal(@@local_domain + "type", domain.type.to_s)
  end
  
  # Test the easy accessors
  def test_easy_accessors
    domain = N::URI.new(@@local_domain)
    assert_equal(@@local_domain + "foo", (domain.foo).to_s)
    assert_equal(@@local_domain + "foo", (domain::foo).to_s)
    assert_equal(@@local_domain + "FoO", (domain.FoO).to_s)
    assert_raise(NoMethodError) { domain.foo(12) }
  end
  
  # Test registering of shortcuts
  def test_shortcuts
    uri = N::URI.new(@@local_domain)
    N::URI.shortcut(:foo, @@local_domain)
    assert_equal(N::FOO, uri)
    assert_kind_of(N::URI, N::FOO)
    assert_raises(NameError) { N::URI.shortcut(:foo, "xxx") }
    assert_raises(NameError) { N::Foo }
  end
  
  # Tests the array-type accessor
  def test_shortcut_accessor
    assert_equal(N::LOCAL, N::URI[:local])
  end
  
  # Test the is_uri? convenience method
  def test_is_uri
    assert(N::URI.is_uri?("http://foobar.org/"))
    assert(N::URI.is_uri?("http://foobar.org/"))
    assert(N::URI.is_uri?("baa:boo"))
    assert(!N::URI.is_uri?("foo"))
  end
  
end
