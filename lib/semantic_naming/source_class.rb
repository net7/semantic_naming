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
    
    # Return a subclass hierarchy
    def self.subclass_hierarchy
      return nil unless(URI.active_rdf?)
      types = rdf_types
      qry = Query.new(SourceClass).distinct.select(:class, :subclass)
      qry.where(:class, RDF.type, RDFS.Class)
      qry.where(:subclass, RDFS.subClassOf, :class)
      subtype_list = qry.execute
      hierarchy = {}
      # Sift through the triples and add the sub-items
      subtype_list.each do |sub_items|
        klass, subklass = sub_items
        hierarchy[klass] ||= {}
        hierarchy[klass][subklass] = true
      end
      
      # Now we link up the subclass relations
      hierarchy.each do |key, values|
        values.each_key do |subkey|
          next if(subkey == :is_child)
          hierarchy[subkey] ||= {}
          values[subkey] = hierarchy[subkey]
          values[subkey][:is_child] = true
        end
      end
      
      # Join with the general types and remove the children
      types.each do |type|
        xtype = (hierarchy[type] ||= {})
        hierarchy.delete(type) if(xtype.delete(:is_child))
      end
      
      hierarchy
    end
    
  end
end