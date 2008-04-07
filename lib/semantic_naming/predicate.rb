module N

  # This is the type of URI that represents a type of predicate
  # (or relation, or property)
  class Predicate < URI
    def namespace
      @namespace ||= local_name.first
    end
    
    def name
      @name ||= local_name.last
    end
    
    private
    def local_name
      to_s.split('/').last.split('#')
    end
  end
end