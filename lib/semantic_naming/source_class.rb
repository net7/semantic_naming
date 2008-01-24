module N

  # This is the type of URI that represents a class of sources. The methods
  # that browse the ontology hierarchy depend on ActiveRDF for accessing the
  # RDF store. If ActiveRDF is not present, these will return nitl.
  class SourceClass < URI
    
    # Match the language part in labels
    @@lang_re = /(.*)@(.+)$/
    
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
    
    # If the RDF store is active and the class has an rdfs:label, this will be
    # returned. Otherwise, this will return the short name of the current source
    # (like ns:name)
    # 
    # You may give a language, if none is given 'en' is used by default. If
    # no label with a language marker is found, the first none-language-label
    # is used
    def label(language = 'en')
      @label ||= label_by_lang(rdfs_labels, language)
      # The rdf label is cache, while the default may change
      return @label ? @label : to_name_s
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
    
    # Gets the rdfs:labels from the rdf store
    def rdfs_labels
      if(active_rdf?)
        labels = make_res(@uri_s)[(N::RDFS::label).to_s]
        if(labels && labels.size > 0)
          labels
        end # else nil
      end # else nil
    end
    
    # Gets the label for the given language. If no labels are given, return nil
    def label_by_lang(labels, language = 'en')
      return nil unless(labels)
      result = nil
      labels.each do |label|
        if(match = @@lang_re.match(label)) # check if there is a "languag" string
          if(match[2] == language)
            return match[1] # We've found one, break here and return the label part
          end
        else
          result ||= label # Keep the non-language label
        end
      end
      
      result
    end
    
  end
end