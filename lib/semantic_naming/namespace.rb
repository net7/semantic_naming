module N
  # This is for URIs that act as namespaces. A namespace
  # is a "prefix" for URIs.
  #
  # Shortcuts for some default namespaces are automatically defined (rdf, owl,
  # ...). See default_namespaces.rb for details. 
  # 
  # Usually there should be no need to change those default namespaces
  class Namespace < N::URI
    
    @@default_namespaces.each do |shortcut, uri|
      Namespace.shortcut(shortcut, uri)
    end
    
    # Finds all members of the given type that are part of this namespace. 
    # *Attention*: Due to the workings of SPARQL this will retrieve *all*
    # elements that match the type and filter them. Thus it's advised to
    # use this only for types of which only a few elements are known to exist
    # (e.g. Onotology classes)
    def elements_with_type(type, element_type = N::URI)
      return unless(rdf_active?)
      qry = ::Query.new.distinct.select(:s)
      qry.where(:s, make_res(RDF::type), make_res(type))
      qry.filter_uri_regexp(:s, "^#{@uri_s}")
      qry.execute.collect { |item| element_type.new(item.uri) }
    end
    
    # Returns a list of predicate names.
    def predicates
      elements_with_type(N::RDF.Property, N::Predicate).map { |p| p.local_name }
    end
  end
end
