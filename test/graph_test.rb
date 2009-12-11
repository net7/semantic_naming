require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
# Test the uri class
class URITest < Test::Unit::TestCase
  
  def test_weeding
    graph = build_test_for_weed
    graph.weed_inference
    test_node(graph, 'a', [], ['c', 'd'])
    test_node(graph, 'b', [], ['d', 'e'])
    test_node(graph, 'c', ['a'], [])
    test_node(graph, 'd', ['a', 'b'], ['f', 'g'])
    test_node(graph, 'e', ['b'], ['h'])
    test_node(graph, 'f', ['d'], ['i'])
    test_node(graph, 'g', ['d'], ['h'])
    test_node(graph, 'h', ['g', 'e'], ['i'])
    test_node(graph, 'i', ['f', 'h'], [])
  end
  
  # Test the tree. This test looks a bit tricky, as the last node
  # can be reached in two ways, and only one will show up in the tree
  #
  # To understand this, best draw the graph from build_test_graph
  def test_tree
    graph = build_test_graph
    # Using the standard test graph, get a tree from the 'd' node
    tree = graph.tree_from('d')
    # Test the parent node
    test_node_direct(tree, [], ['f', 'g'])
    # flag to show that we have arrived at the 'i' node on exactly
    # one of the possible paths
    i_reached = false
    # Test the two direct children of the parent node,
    # which should be f and g
    tree.subclasses.each do |sub|
      if(sub.to_s == 'f')
        # We are on the f node. 
        # Check if we can reach the i node through f 
        # The 'i' node can either be reached through f, or
        # through g-h
        if(sub.subclasses.size == 1)
          # We have found the i node
          test_node_direct(sub, ['d'], ['i'])
          i_reached = true
        else
          test_node_direct(sub, ['d'], [])
        end
      elsif(sub.to_s == 'g')
        # We are in the g node, coming from d.
        # The next node will be 'h', and then we can
        # either find 'i' (if not found through 'f')
        # or not
        test_node_direct(sub, ['d'], ['h'])
        assert_equal(1, sub.subclasses.size)
        # Check if we find the h node
        hnode = sub.subclasses.first
        assert_equal('h', hnode.to_s)
        # look for the i node on this path, if it wasn't found above
        if(hnode.subclasses.size == 0)
          test_node_direct(hnode, ['g'], [])
        else
          assert_not(i_reached)
          test_node_direct(hnode, ['g'], ['i'])
          i_reached = true
        end
      else
        fail
      end
    end
    assert(i_reached)
  end
  
  private
  
  def test_node(graph, node_name, superclasses, subclasses)
    test_node_direct(graph.get_node(node_name), superclasses, subclasses)
  end
  
  def test_node_direct(node, superclasses, subclasses)
    assert_equal(node.superclasses.collect {|c| c.to_s }.sort, superclasses.sort)
    assert_equal(node.subclasses.collect {|c| c.to_s }.sort, subclasses.sort)
  end
  
  # Build the test graph for weeding out the inferred relations.
  # 
  # The tree is the build_test_graph plus
  # the corresponding "direct" superclass and subclass relations
  def build_test_for_weed
    graph = build_test_graph
    
    graph.add_relation('a', 'a')
    graph.add_relation('a', 'f')
    graph.add_relation('a', 'g')
    graph.add_relation('a', 'h')
    graph.add_relation('a', 'i')
    graph.add_relation('b', 'b')
    graph.add_relation('c', 'c')
    graph.add_relation('d', 'd')
    graph.add_relation('d', 'h')
    graph.add_relation('d', 'i')
    graph.add_relation('e', 'e')
    graph.add_relation('f', 'f')
    graph.add_relation('g', 'g')
    graph.add_relation('h', 'h')
    graph.add_relation('i', 'i')
    graph.add_relation('g', 'i')
    graph.add_relation('b', 'f')
    graph.add_relation('b', 'g')
    graph.add_relation('b', 'h')
    graph.add_relation('b', 'i')
    graph.add_relation('e', 'i')
    graph
  end
  
  # Build a test graph
  # 
  # The tree is 
  # A -> [C, D]
  # B -> [D, E]
  # D -> [F, G]
  # E -> [H]
  # F -> [I]
  # G -> [H]
  # H -> [I]
  #
  def build_test_graph
    graph = OntologyGraph::Graph.new
    
    graph.add_relation('a', 'c')
    graph.add_relation('a', 'd')
    graph.add_relation('d', 'f')
    graph.add_relation('d', 'g')
    graph.add_relation('f', 'i')
    graph.add_relation('g', 'h')
    graph.add_relation('h', 'i')
    graph.add_relation('b', 'd')
    graph.add_relation('b', 'e')
    graph.add_relation('e', 'h')
    graph
  end
  
end