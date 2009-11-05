module N

  # This is the type of URI that represents a class of sources. The methods
  # that browse the ontology hierarchy depend on ActiveRDF for accessing the
  # RDF store. If ActiveRDF is not present, these will return nitl.
  class SourceClass < URI
    
    # Get the supertype of this class
    def supertypes
      return nil unless(active_rdf? && is_iri?)
      qry = Query.new(SourceClass).distinct.select(:o)
      qry.where(self, RDFS.subClassOf, :o)
      qry.where(:o, RDF.type, RDFS.Class)
      qry.execute
    end
    
    # Get the subtypes of this type
    def subtypes
      return nil unless(active_rdf? && is_iri?)
      qry = Query.new(SourceClass).distinct.select(:s)
      qry.where(:s, RDFS.subClassOf, self)
      qry.where(:s, RDF.type, RDFS.Class)
      qry.execute
    end
    
    # Get the instances of this type. return_type will be the class used to 
    # create the objects that are returned.
    def instances(return_type)
      return nil unless(active_rdf? && is_iri?)
      qry = Query.new(SourceClass).distinct.select(:s)
      qry.where(:s, RDF.type, self)
      qry.execute
    end
    
    # Get all the existing types from the RDF store
    def self.rdf_types
      return nil unless(URI.active_rdf?)
      qry = Query.new(SourceClass).distinct.select(:s)
      qry.where(:s, RDF.type, RDFS.Class)
      qry.execute
    end
    
    # Return a subclass hierarchy. This is quicker than going through
    # the hierarchy step by step. It will look at all subclass (*not*
    # superclass!) relationships and return a nested, tree-like structure
    # build of hashes. Each key in the hash will be the class object, and
    # the values are hashes with the child elements, and so on
    #
    # E.g. : { type1 => { subtype_a => {}, subtype_b => { xtype => {}} }, type_2 => {}}
    def self.subclass_hierarchy
      return nil unless(URI.active_rdf?)
      types = rdf_types
      qry = Query.new(SourceClass).distinct.select(:class, :subclass)
      qry.where(:class, RDF.type, RDFS.Class)
      qry.where(:subclass, RDFS.subClassOf, :class)
      subtype_list = qry.execute
      
      build_hierarchy_from(subtype_list, rdf_types)
    end
    
    # This works like the subclass_hierarchy method, with the exception that
    # 
    # * Ontology information is only used for subtype relations
    # * Resources are considered a "type" if they appear as an rdf:type attribute
    # * Only types that are actively used (that is they appear as an rdf:type attribute)
    #   are included
    def self.used_subclass_hierarchy
      all_types_qry = Query.new(SourceClass).distinct.select(:type)
      all_types_qry.where(:element, RDF.type, :type)
      all_types = all_types_qry.execute
      
      qry = Query.new(SourceClass).distinct.select(:class, :subclass)
      qry.where(:subclass, RDFS.subClassOf, :class)
      subtype_list = qry.execute
      
      all_types_hash = {}
      all_types.each { |type| all_types_hash[type] = true }
      
      # TODO: Not very efficient, but then we don't expect many types
      all_type_list = (all_types + subtype_list.collect { |el| el.last }).uniq
      
      hierarchy = build_hierarchy_from(subtype_list, all_type_list)
      
      purge_hierarchy!(hierarchy, all_types_hash)
      
      hierarchy
    end
    
    private
    
    # Purge the elements from the hierarchy that don't have any "used"
    # children. Returns true if some "used" elements were found in
    # the hierarchy
    def self.purge_hierarchy!(elements, used_elements)
      used = false
      elements.each do |element, children|
        used_children = purge_hierarchy!(children, used_elements)
        used_element = used_children || used_elements[element]
        elements.delete(element) unless(used_element)
        used ||= used_element
      end
      used
    end
    
    # If all_types is given, it must be a true superset of all
    # types in the query result
    def self.build_hierarchy_from(query_result, all_types = nil)
      hierarchy = {}
      # Sift through the triples and add the sub-items
      query_result.each do |sub_items|
        klass, subklass = sub_items
        hierarchy[klass] ||= {}
        hierarchy[klass][subklass] = true
      end
      
      # Now we link up the subclass relations
      hierarchy.each do |key, values|
        values.each_key do |subkey|
          next if(subkey.is_a?(Symbol))
          hierarchy[subkey] ||= {}
          values[subkey] = hierarchy[subkey]
          values[subkey][:is_child] = true
        end
      end
      
      all_types ||= hierarchy.keys
      
      # Join with the general types and remove the children
      all_types.each do |type|
        xtype = (hierarchy[type] ||= {})
        hierarchy.delete(type) if(xtype.delete(:is_child))
      end
      
      hierarchy.delete(N::RDFS.Class)
      hierarchy.delete(N::OWL.Class) if(defined?(N::OWL))
      
      hierarchy
    end
    
  end
end