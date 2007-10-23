module N

  # This is the type of URI that represents a class of sources
  class SourceClass < URI
    
    # Get the supertype of this class
    def supertype
      qry = Query.new.distinct.select(:o)
      qry.where(Module::RDFS::Resource.new(@uri_s), Module::RDFS::Resource.new(RDFS::subClassOf.to_s), :o)
      qry.where(:s, Module::RDFS::Resource.new(RDF::type.to_s), Module::RDFS::Resource.new((RDFS + 'Class').to_s))
      results = qry.execute
      raise(SemanticNamingError, "Type with multiple supertypes found") if(results && results.size > 1)
      (results && results.size == 1) ? SourceClass.new(results[0].uri) : nil
    end
    
    # Get the subtypes of this type
    def subtypes
      qry = Query.new.distinct.select(:s)
      qry.where(:s, Module::RDFS::Resource.new(RDFS::subClassOf.to_s), Module::RDFS::Resource.new(@uri_s))
      qry.where(:s, Module::RDFS::Resource.new(RDF::type.to_s), Module::RDFS::Resource.new((RDFS + 'Class').to_s))
      qry.execute.collect { |item| SourceClass.new(item.uri) }
    end
    
    # Get the instances of this type
    def instances
      qry = Query.new.distinct.select(:s)
      qry.where(:s, Module::RDFS::Resource.new(RDF::type.to_s), Module::RDFS::Resource.new(@uri_s))
      qry.execute.collect { |item| TaliaCore::Source.new(item.uri) }
    end
    
  end
end