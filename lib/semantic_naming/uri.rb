module N
  
  # This class contains basic functionality for URIs
  class URI
  
    # Should behave like an ActiveRDF resource
    include RDFS::ResourceLike
    
    # Contains the registered uris
    @@registered_uris = Hash.new
    
    # Contains an inverse hash to lookup the shortcuts by uir
    @@inverse_register = Hash.new
    
    # Regexp that can match the part up until last # or / character,
    # and the part behind that (domain, localname)
    @@domainsplit_re = Regexp.compile("(.*[/#])([^/#]*)$")
    
    # Match the language part in labels
    @@lang_re = /(.*)@(.+)$/
  
    # make some builtin methods private because lookup doesn't work otherwise 
    # on e.g. RDF::type and FOAF::name
    [:type, :id].each {|m| private(m) }
  
    # Create a new URI
    def initialize(uri_s)
      uri_s = uri_s.to_s
      # TODO: More checking
      @uri_s = uri_s
    end
    
    # Compare operator
    def ==(object)
      return true if eql?(object)
      return object == @uri_s if(object.kind_of?(String))
      return false
    end
    
    # eql? compare operator
    def eql?(object)
      return object.to_s == @uri_s if(object.kind_of?(URI))
      return false
    end
    
    # Returns a hash
    def hash
      @uri_s.hash
    end
    
    # Add operator
    def +(uri)
      new_s = @uri_s + uri.to_s
      return URI.new(new_s)
    end
    
    # Checks if the current URI is local
    def local?
      N::LOCAL.domain_of?(self)
    end
    
    # Redirect for checking if this is remote
    def remote?
      !local?
    end
    
    # String representation is the uri itself
    def to_s
      @uri_s
    end
    
    # YAML representation is the uri string
    def to_yaml
      self.to_s.to_yaml
    end
    
    # Alias "uri" for compatibility with ActiveRDF
    alias_method :uri, :to_s
    
    # Get a string representation in the form of 'namespace:name'. It is 
    # possible to select a different separator from ':'
    #
    # If this uri is not part of a namespace, the whole uri string will
    # be returned.
    def to_name_s(separator = ':')
      nspace = namespace
      if(nspace)
        "#{nspace}#{separator}#{local_name}"
      else
        @uri_s
      end
    end
    
    # This creates a helpers for a nice notation of
    # like my_domain::myid
    def const_missing(klass)
      return URI.new(@uri_s + klass.to_s)
    end
    
    # See const_missing
    def method_missing(method, *args)
      # Quick sanity check: args make no sense for this
      raise(NoMethodError, "Undefined method: " + method.to_s) if(args && args.size > 0)    
      
      return URI.new(@uri_s + method.to_s)
    end
    
    # Is true if this object describes the domain of the
    # given uri, and the given uri is a resource in that
    # domain
    def domain_of?(uri)
      uri_s = uri.to_s
      
      (uri_s =~ /\A#{@uri_s}\w*/) != nil
    end
    
    # Request URI by shortcut. If called on a sublass, this accessor
    # will only return an URI if it's of the same type as the subclass.
    def self.[](shortcut)
      shortcut = shortcut.to_s.downcase.to_sym
      
      uri = @@registered_uris[shortcut]
      
      # We only return the uri if it's of the same kind as ourselves
      uri.kind_of?(self) ? uri : nil 
    end
    
    # Returns a hash with all registered shortcuts.
    # This will only return the shortcuts of the same class (and subclasses)
    # than the one on which the method is called
    def self.shortcuts
      shortcuts = {}
      @@registered_uris.each do |key, value|
        shortcuts[key] = value if(value.kind_of?(self))
      end
      
      shortcuts
    end
    
    # Check if a shortcut is registered
    def self.shortcut_exists?(shortcut)
      @@registered_uris[shortcut.to_s.downcase.to_sym] != nil
    end
    
    # Get an URI string from the given string in ns:name notation
    def self.make_uri(str, separator = ":", default_namespace = N::LOCAL)
      type = str.split(separator)
      type = [type[1]] if(type[0] == "")
      if(type.size == 2)
        namespace = N::URI[type[0]]
        raise(ArgumentError, "Unknown namespace #{type[0]} for #{str}") unless(namespace)
        self.new(namespace + type[1])
      else
        default_namespace + type[0]
      end
    end
    
    # Returns the local name
    def local_name
      localname = nil
      
      if(md = @@domainsplit_re.match(@uri_s))
        localname = md[2]
      end
      
      localname
    end
    
    # Returns the domain part of the URI
    def domain_part
      domainpart = nil
      
      if(md = @@domainsplit_re.match(@uri_s))
        domainpart = md[1]
      end
      
      domainpart ? URI.new(domainpart) : nil
    end
    
    # Returns the shortcut for the current URI, or nil
    # if no shortcut is defined for this URI
    def my_shortcut
      @@inverse_register[@uri_s]
    end
    
    # Returns the namespace of this URI, if the URI
    # is part of a namespace. The rule is quite strict:
    # The URI is only part of the namespace if it is the
    # namespace itself or the namespace plus a single local part
    # 
    # If the URI is not part of a namespace, nil is returned
    def namespace
      nspace = nil
      
      domain_shortcut = domain_part.my_shortcut
      
      if(domain_shortcut && URI[domain_shortcut].is_a?(Namespace))
        nspace = domain_shortcut
      end
      
      nspace
    end
    
    # Register a shortcut to the given URI. You may force to overwrite an 
    # existing shortcut, but this is not recommended. The option exists practically
    # only to override default namespaces if there is a need.
    def self.shortcut(shortcut, uri, force = false)
      shortcut = shortcut.to_s.downcase.to_sym
      constant = shortcut.to_s.upcase.to_sym
      
      # make an object of my own type
      uri = self.new(uri)
      
      if(!force && (@@registered_uris[shortcut] || N.const_defined?(constant)))
        raise(NameError, "Shortcut already defined: '#{shortcut.to_s}'")
      end
      
      if(!force && (@@inverse_register[uri.to_s]))
        raise(NameError, "Shortcut for this uri already exists: #{uri.to_s}")
      end
      
      @@registered_uris[shortcut] = uri
      @@inverse_register[uri.to_s] = shortcut
      N.const_set(constant, uri)
      
      return uri
    end
    
    # Check if a given string is an URI
    def self.is_uri?(uri_str)
      uri_str =~ /:/
    end
    
    # If the RDF store is active and the class has an rdfs:label, this will be
    # returned. Otherwise, this will return the short name of the current source
    # (like ns:name)
    # 
    # You may give a language, if none is given 'en' is used by default. If
    # no label with a language marker is found, the first none-language-label
    # is used
    def rdf_label(language = 'en')
      @labels ||= {}
      @labels[language] ||= label_by_lang(rdfs_labels, language)
      # The rdf label is cache, while the default may change
      @labels[language] ||= to_name_s
      @labels[language]
    end
    
    # to_uri just returns a clone of itself
    def to_uri
      self.clone
    end
    
    private
    
    # Check if the ActiveRDF library is present.
    def self.active_rdf?
      unless(defined?(@active_rdf))
        @active_rdf = defined?(::ConnectionPool) &&  (::ConnectionPool.read_adapters.size > 0)
      end
      
      @active_rdf
    end
    
    # See the respective class method
    def is_iri?
      self.class.is_iri?(@uri_s)
    end
    
    # Checks if the current URI is a valid IRI (special for of URI defined
    # in the SPARQL spec). URIs that are not IRIs may cause problems with
    # SPARQL queries.
    def self.is_iri?(string)
      (string =~ /[{}|\\^`\s]/) == nil
    end
    
    # RDF check, this is a convenience for instances
    def active_rdf?
      URI.active_rdf?
    end
    
    # Gets the rdfs:labels from the rdf store
    def rdfs_labels
     if(active_rdf? && is_iri?)
        labels = Query.new(N::URI).distinct.select(:label).where(self, N::RDFS.label, :label).execute
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
        if(match = @@lang_re.match(label)) # check if there is a "language" string
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
