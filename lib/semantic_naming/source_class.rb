module N

  # This is the type of URI that represents a class of sources. Each SourceClass 
  # object is part of the internal class graph. If an ActiveRDF connection is
  # present, it is possible to quickly navigate through the type hierarchy.
  #
  # The class hierarchy is base on the OntologyGraph structures - it will not
  # show inferred types as subtypes or supertypes of the current class.
  # 
  # The graph of the class realtions will usually be cached, it can be reset
  # by passing allow_caching = false to the respective methods.
  class SourceClass < URI
    
    # Get the supertype of this class
    def supertypes(allow_caching = true)
      my_node(allow_caching).superclasses.collect { |st| SourceClass.new(st.uri) }
    end
    
    # Get the subtypes of this type
    def subtypes(allow_caching = true)
      my_node(allow_caching).subclasses.collect { |st| SourceClass.new(st.uri) }
    end
    
    # Get the instances of this type. return_type will be the class used to 
    # create the objects that are returned. This will not use the cached
    # graph but cause an RDF query on each call
    def instances(return_type)
      return nil unless(active_rdf? && is_iri?)
      qry = ActiveRDF::Query.new(URI).distinct.select(:s)
      qry.where(:s, RDF.type, self)
      qry.execute
    end
    
    # Returns the ClassNode element related to this class. This
    # will return a "dummy" element when the node is not found in
    # the graph
    def my_node(allow_caching = true)
      graph = SourceClass.class_graph(allow_caching)
      graph.get_node(@uri_s) || OntologyGraph::ClassNode.new(@uri_s)
    end
    
    # Return all the existing types as a list of SourceClass objects
    def self.rdf_types(allow_caching = true)
      graph = class_graph(allow_caching)
      return nill unless(graph)
      graph.collect { |n| SourceClass.new(n.uri) }
    end
    
    # Get all the existing types from the RDF store. Return the class
    # graph directly
    def self.class_graph(allow_caching = true)
      return @class_graph if(allow_caching && @class_graph)
      @class_graph = OntologyGraph::Graph.new
      @class_graph.build_from_ardf if(URI.active_rdf?)
      @class_graph
    end
    
    # Return a subclass hierarchy. This is quicker than going through
    # the hierarchy step by step. It will look at all subclass (*not*
    # superclass!) relationships and return a nested, tree-like structure
    # build of hashes. Each key in the hash will be the class object, and
    # the values are hashes with the child elements, and so on
    #
    # E.g. : { type1 => { subtype_a => {}, subtype_b => { xtype => {}} }, type_2 => {}}
    #
    # If a block is passed, it will receive the ClassNode object of each
    # class in the graph. If the block returns false, this class will not
    # be included in the hierarchy if possible (that is, if the class is a leaf)
    def self.subclass_hierarchy(root_list = nil, allow_caching = true, &block)
      graph = SourceClass.class_graph(allow_caching)
      
      if(root_list)
        root_list.collect! { |el| el.is_a?(OntologyGraph::ClassNode) ? el : OntologyGraph::ClassNode.new(el) }
      else
        root_list = []
        graph.each_node { |n| root_list << n if(n.superclasses.empty?) }
      end
      
      hierarchy = {}
      root_list.each do |root_el|
        remove = (block == nil) ? false : !block.call(root_el)
        sub_hierarchy = subclass_hierarchy(root_el.subclasses, allow_caching, &block)
        remove = remove && sub_hierarchy.empty?
        hierarchy[N::URI.new(root_el.uri.to_s)] = sub_hierarchy unless(remove)
      end
      
      hierarchy
    end
    
    
  end
end