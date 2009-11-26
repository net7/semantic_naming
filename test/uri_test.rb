require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
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
  def test_shortcut_register
    uri = N::URI.new("http://foo.foo.com/")
    N::URI.shortcut(:foo, uri.to_s)
    assert_equal(N::FOO, uri)
    assert_kind_of(N::URI, N::FOO)
  end
  
  # Test the shortcuts method
  def test_shortcuts
    N::URI.shortcut(:at_least_one, "http://atleast.com")
    N::URI.shortcut(:at_least_two, "http://atleasttwo.com")
    assert(N::URI.shortcuts.size > 1, "There should be at least two shortcuts")
    assert(N::URI.shortcuts.keys.include?(:at_least_one))
    assert(N::URI.shortcuts.keys.include?(:at_least_two))
  end
  
  # Test if the assignment of illegal shortcuts fails correctly
  def test_illegal_shortcuts
    N::URI.shortcut(:illegal_short, "http://illegal.shortcut.com/")
    assert_raises(NameError) { N::URI.shortcut(:illegal_short, "xxx") }
    assert_raises(NameError) { N::URI.shortcut(:legal_short, "http://illegal.shortcut.com/")}
  end
  
  # Checks if nonexistent/illegal shortcuts fail correctly
  def test_nonexistent_shortcut 
    assert_raises(NameError) { N::Foo }
  end
  
  # Tests the array-type accessor
  def test_shortcut_accessor
    assert_equal(N::LOCAL, N::URI[:local])
  end
  
  # Test array-type accessor with subclass
  def test_shortcut_accessor_subclass
    namesp = N::Namespace.shortcut(:uri_array_ns_short, "http://test_shortcut_accessor_subclass/")
    assert_equal(namesp, N::URI[:uri_array_ns_short])
  end
  
  # Test the is_uri? convenience method
  def test_is_uri
    assert(N::URI.is_uri?("http://foobar.org/"))
    assert(N::URI.is_uri?("http://foobar.org/"))
    assert(N::URI.is_uri?("baa:boo"))
    assert(!N::URI.is_uri?("foo"))
  end
  
  # Try to get the shortcut from a URL
  def test_check_shortcut
    N::Namespace.shortcut(:xyshortcut, "http://xyz/")
    assert_equal(:xyshortcut, N::URI.new("http://xyz/").my_shortcut)
  end
  
  # Try to get inexistent shortcut from a URL
  def test_inexistent_shortcut
    assert_equal(nil, N::URI.new("http://noshortcut/").my_shortcut)
  end
  
  # Try to get the local name of an uri
  def test_local_name
    assert_equal("master", N::URI.new("http://somethingelse.com/master").local_name)
    assert_equal("slave", N::URI.new("http://somethingelse.com/master#slave").local_name)
    assert_equal("chicken", N::URI.new("http://somethingelse.com/animals/chicken").local_name)
  end
  
  # Special case for local name
  def test_only_local_name
    assert_equal(nil, N::URI.new("file:thingy").local_name)
  end
  
  # Only domain, no local
  def test_inexistent_local_name
    assert_equal("", N::URI.new("http://somethingelse.com/").local_name)
  end
  
  # Try to get the path name of an uri
  def test_domain_part
    assert_kind_of(N::URI, N::URI.new("http://somethingelse.com/foobar/bla/").domain_part)
    assert_equal("http://somethingelse.com/foobar/bla/", N::URI.new("http://somethingelse.com/foobar/bla/").domain_part.to_s)
    assert_equal("http://somethingelse.com/foobar/bla/", N::URI.new("http://somethingelse.com/foobar/bla/thing").domain_part.to_s)
    assert_equal("http://somethingelse.com/foobar/bla#", N::URI.new("http://somethingelse.com/foobar/bla#thong").domain_part.to_s)
  end
  
  # Test special URI with no domain
  def test_no_domain
    assert_equal(nil, N::URI.new("file:thingy").domain_part)
  end
  
  # Try to get the namspace of an uri
  def test_namespace
    N::Namespace.shortcut(:test_namespace, "http://test_namespace/")
    assert_equal(:test_namespace, N::URI.new("http://test_namespace/").namespace)
    assert_equal(:test_namespace, N::URI.new("http://test_namespace/else").namespace)
    assert_equal(nil, N::URI.new("http://test_namespace/else/other").namespace)
  end
  
  # No namespace
  def test_namespace_inexistent
    assert_equal(nil, N::URI.new("http://unrelated").namespace)
  end
  
  # Test make_uri
  def test_make_uri
    N::Namespace.shortcut(:makeuri, "http://test_makeuri/")
    uri = N::URI.make_uri("makeuri:foo")
    assert_equal("http://test_makeuri/foo", uri.to_s)
  end
  
  # Test namespace with shortcut of wrong time
  def test_not_defined_as_namespace
    N::URI.shortcut(:not_namespace, "http://iamnotanamespace/")
    assert_equal(nil, N::URI.new("http://iamnotanamespace/").namespace)
  end
  
  def test_to_uri
    uri = N::URI.new('http://someotheruri.com/test.pdf')
    assert_equal(uri, uri.to_uri)
    assert_not_same(uri, uri.to_uri)
  end
  
  # Test rdf label
  def test_rdf_label
    uri = N::URI.new(N::RDFTEST::test1)
    if(RDF_ACTIVE)
      assert_equal("Like a virgin", uri.rdf_label('it'))
      assert_equal("come on", uri.rdf_label('en'))
      assert_equal("come on", uri.rdf_label)
    else
      assert_equal("rdftest:test1", uri.rdf_label('it'))
    end
  end
  
  def test_to_name_s
    assert_equal('rdftest:foo', N::RDFTEST.foo.to_name_s)
  end
  
  def test_to_name_s_separator
    assert_equal('rdftest#foo', N::RDFTEST.foo.to_name_s('#'))
  end
  
  def test_to_name_s_nogo
    assert_equal('http://unknownnamespacething.com/thing', N::URI.new('http://unknownnamespacething.com/thing').to_name_s)
  end
  
  def test_hash
    assert_equal(N::RDFTEST.testme.to_s.hash, N::RDFTEST.testme.hash)
  end
  
end
