module N
  
  # This class contains basic functionality for URIs
  class URI
  
    # Contains the registered uris
    @@registered_uris = Hash.new
    
    # Contains an inverse hash to lookup the shortcuts by uir
    @@inverse_register = Hash.new
    
    # Regexp that can match the part up until last # or / character,
    # and the part behind that (domain, localname)
    @@domainsplit_re = Regexp.compile("(.*[/#])([^/#]*)$")
  
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
      return object.to_s == @uri_s if(object.kind_of?(URI))
      return object == @uri_s if(object.kind_of?(String))
      return false
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
    
    # Request URI by shortcut
    def self.[](shortcut)
      shortcut = shortcut.to_s.downcase.to_sym
      
      @@registered_uris[shortcut]
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
    
    # Register a shortcut to the given URI
    def self.shortcut(shortcut, uri)
      shortcut = shortcut.to_s.downcase.to_sym
      constant = shortcut.to_s.upcase.to_sym
      
      # make an object of my own type
      uri = self.new(uri)
      
      if(@@registered_uris[shortcut] || N.const_defined?(constant))
        raise(NameError, "Shortcut already defined: '#{shortcut.to_s}'")
      end
      
      if(@@inverse_register[uri.to_s])
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
    
  end
end
