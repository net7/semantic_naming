module OntologyGraph

  # Class for handling the graph of ontology classes. This allows
  # quick access to each RDFS class know to the system.
  #
  # If ActiveRDF is available, the graph can initialize itself from
  # the RDF store and allows access to all the subclass and superclass
  # relations in the system.
  class Graph
    
    include Enumerable
    
    # Create a new class graph
    def initialize
      @class_hash = {}
    end
    
    # Add a relation between a subclass or a superclass
    def add_relation(superclass, subclass)
      subclass = get_or_create_node(subclass)
      superclass = get_or_create_node(superclass)
      return if(subclass.uri == superclass.uri) # don't accept self-relations
      superclass.add_subclass(subclass)
    end
    
    # Retrieve the graph node for the given name/URL. If the node 
    # does not already exist, it will be created. 
    def get_or_create_node(name)
      node = get_node(name)
      return node if(node)
      node = ClassNode.new(name)
      @class_hash[name] = node
      node
    end
    
    def get_node(name)
      @class_hash[name.to_s]
    end
    
    # Iterate through each node
    def each(&block)
      @class_hash.each_value(&block)
    end
    alias :each_node :each
    
    # Build the whole graph from the RDF store. This will include all Resources that
    # are either marked as an rdfs:class orare used as an rdf:type and all the subclass
    # relations between them. 
    def build_from_ardf
      return unless(N::URI.active_rdf?)
      
      # First select all classes and add them as nodes
      class_qry = ActiveRDF::Query.new(N::URI).select(:class).where(:class, N::RDF.type, N::RDFS.Class)
      types = class_qry.execute
      types.each { |t| @class_hash[t.to_s] = ClassNode.new(t.to_s) }
      
      # Now, look for all subclass relationships and add them
      subtype_qry = ActiveRDF::Query.new(N::URI).distinct.select(:class, :subclass)
      subtype_qry.where(:subclass, RDFS.subClassOf, :class)
      subtype_list = subtype_qry.execute
      subtype_list.each  { |cl, subcl| add_relation(cl, subcl) }
      
      # Flag all classes that are actually used
      used_types_qry = ActiveRDF::Query.new(N::URI).distinct.select(:type)
      used_types_qry.where(:element, RDF.type, :type)
      used_types = used_types_qry.execute
      used_types.each { |t| get_or_create_node(t).flag_used }
      
      weed_inference
      
    end
    
    # Reset the flags for tree walking on all nodes of the tree.
    def reset_flags
      @class_hash.each_value { |n| n.flags = nil }
    end
    
    # Create a tree of subclasses, starting from the given node.
    # This will return a ClassNode which is the root of a tree of 
    # all classes that are reachable from the current node as subclasses.
    def tree_from(node_name, &block)
      reset_flags
      make_tree_from(node_name, &block)
    end
    
    # Weed out "inferred" subclass relationships from the graph, if
    # they exist.
    def weed_inference
      root_elements = []
      @class_hash.each_value do |node|
        if(node.superclasses.empty?)
          root_elements << node
        end
      end
      
      raise(RuntimeError, "No root elements in the graph, ontology graph cannot by cyclic") if(root_elements.empty?)

      root_elements.each { |root| root.weed_superclasses }
    end
    
    private 
    
    # See #tree_from
    def make_tree_from(node_name)
      node_name = node_name.to_s
      start = get_or_create_node(node_name)
      root = ClassNode.new(node_name)
      start.flags = :visited
      start.subclasses.each do |sub| 
        next if(sub.flags == :visited)
        accepted = block_given? ? yield(sub) : true
        root.add_subclass(make_tree_from(sub)) unless(!accepted && (sub.subclasses.size == 0))
      end
      root
    end
    
  end

end