module N

  # This is the type of URI that represents a class of sources. The methods
  # that browse the ontology hierarchy depend on ActiveRDF for accessing the
  # RDF store. If ActiveRDF is not present, these will return nitl.
  class SourceClass < URI
    
    # Get the supertype of this class
    def supertypes
      return nil unless(active_rdf? && is_iri?)
      qry = Query.new.distinct.select(:o)
      qry.where(make_res(@uri_s), make_res(RDFS::subClassOf), :o)
      qry.where(:o, make_res(RDF::type), make_res(RDFS + 'Class'))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
    # Get the subtypes of this type
    def subtypes
      return nil unless(active_rdf? && is_iri?)
      qry = Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDFS::subClassOf), make_res(@uri_s))
      qry.where(:s, make_res(RDF::type), make_res(RDFS + 'Class'))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
    # Get the instances of this type. return_type will be the class used to 
    # create the objects that are returned.
    def instances(return_type)
      return nil unless(active_rdf? && is_iri?)
      qry = Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDF::type.to_s), make_res(@uri_s))
      qry.execute.collect { |item| return_type.new(item.uri) }
    end
    
    # Get all the existing types from the RDF store
    def self.rdf_types
      return nil unless(URI.active_rdf?)
      qry = Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDF::type), make_res(RDFS + 'Class'))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
  end
end