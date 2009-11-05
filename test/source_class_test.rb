require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

  
# Test the uri class
class TypeTest < Test::Unit::TestCase
  
  # Tests the basic registering of namespaces
  def test_shortcut
    new_sc = N::SourceClass.shortcut(:newsc, "http://www.source_shortcut.com/")
    assert_equal(new_sc, N::NEWSC);
    assert_equal(new_sc.to_s, "http://www.source_shortcut.com/")
    assert_equal(new_sc, N::URI.new("http://www.source_shortcut.com/"))
    assert_kind_of(N::SourceClass, new_sc)
    assert_kind_of(N::SourceClass, N::NEWSC)
    assert_raise(NameError) { N::Namespace.shortcut(:newsc, "http://www.source_shortcut.com/") }
  end
  
  # Test the supertypes method
  def test_supertypes
    return unless(RDF_ACTIVE)
    src = N::SourceClass.new(N::RDFTEST.Type1)
    subtypes = src.subtypes.collect { |type| type.uri.to_s }
    assert_equal([N::RDFTEST.Type2.to_s, N::RDFTEST.Type3.to_s].sort, subtypes.sort)
  end
  
  def test_subtypes
    return unless(RDF_ACTIVE)
    src = N::SourceClass.new(N::RDFTEST.Type3)
    supertypes = src.supertypes.collect { |type| type.uri.to_s }
    assert_equal([N::RDFTEST.Type1.to_s, N::RDFTEST.Type4.to_s].sort, supertypes.sort)
  end
  
  def test_instances
    return unless(RDF_ACTIVE)
    src = N::SourceClass.new(N::RDFTEST.Type1)
    instances = src.instances(N::URI).collect { |type| type.uri.to_s }
    assert_equal([N::RDFTEST.test1.to_s, N::RDFTEST.test2.to_s, N::RDFTEST2.test1.to_s, N::RDFTEST2.test2.to_s].sort, instances.sort)
  end
  
  def test_rdf_types
    return unless(RDF_ACTIVE)
    types = N::SourceClass.rdf_types.collect { |type| type.uri.to_s }
    assert_equal([N::RDFTEST.Type1.to_s, N::RDFTEST.Type2.to_s, N::RDFTEST.Type3.to_s, N::RDFTEST.Type4.to_s].sort, types.sort)
  end
  
  def test_subclass_hierarchy
    hierarchy = N::SourceClass.subclass_hierarchy
    assert_equal({N::RDFTEST.Type1 => { N::RDFTEST.Type2 => {}, N::RDFTEST.Type3 => {} }, N::RDFTEST.Type4 => { N::RDFTEST.Type3 => {}}}, hierarchy)
  end
  
  def test_used_subclass_hierarchy
    hierarchy = N::SourceClass.used_subclass_hierarchy
    assert_equal({N::RDFTEST.Type1 => { N::RDFTEST.Type2 => {}}}, hierarchy)
  end
  
end
