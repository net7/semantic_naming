module N

  # This is the type of URI that represents a class of sources. The methods
  # that browse the ontology hierarchy depend on ActiveRDF for accessing the
  # RDF store. If ActiveRDF is not present, these will return nitl.
  class SourceClass < URI
    
    # Get the supertype of this class
    def supertypes
      return nil unless(active_rdf?)
      qry = Query.new.distinct.select(:o)
      qry.where(make_res(@uri_s), make_res(RDFS::subClassOf), :o)
      qry.where(:o, make_res(RDF::type), make_res(RDFS + 'Class'))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
    # Get the subtypes of this type
    def subtypes
      return nil unless(active_rdf?)
      qry = Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDFS::subClassOf), make_res(@uri_s))
      qry.where(:s, make_res(RDF::type), make_res(RDFS + 'Class'))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
    # Get the instances of this type
    def instances
      return nil unless(active_rdf?)
      qry = Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDF::type.to_s), make_res(@uri_s))
      qry.execute.collect { |item| TaliaCore::Source.new(item.uri) }
    end
    
    # Get all the existing types from the RDF store
    def self.rdf_types
      return nil unless(active_rdf?)
      qry = Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDF::type), make_res(RDFS + 'Class'))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
    protected
    
    # Create a resource from the given type
    def make_res(type)
      Module::RDFS::Resource.new(type.to_s)
    end
    
    @@active_rdf_checked = false
    
    # Check if the ActiveRDF library is present.
    def active_rdf?
      unless(@@active_rdf_checked)
        @@active_rdf_present = defined?(Module::RDFS::Resource)
        @@active_rdf_checked = true
      end
      
      @@active_rdf_present
    end
    
  end
end