module N
  
  # This class contains basic functionality for URIs
  class URI
  
    # Contains the registered uris
    @@registered_uris = Hash.new
  
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
      shortcut = shortcut.to_s.upcase.to_sym
      
      @@registered_uris[shortcut]
    end
    
    
    # Register a shortcut to the given URI
    def self.shortcut(shortcut, uri)
      shortcut = shortcut.to_s.upcase.to_sym
      # make an object of my own type
      uri = self.new(uri)
      
      if(@@registered_uris[shortcut] || N.const_defined?(shortcut))
        raise(NameError, "Shortcut already defined: '#{shortcut.to_s}'")
      end
      
      @@registered_uris[shortcut] = uri
      N.const_set(shortcut, uri)
      
      return uri
    end
    
    # Check if a given string is an URI
    def self.is_uri?(uri_str)
      uri_str =~ /:/
    end
    
  end
end
