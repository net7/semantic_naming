module OntologyGraph
  
  # Helper class that contains a node in the internal RDFS/OWL class graph
  class ClassNode
    
    attr_accessor :subclasses, :superclasses, :uri, :flags
    
    # Create a new unconnected node with the given uri
    def initialize(uri)
      @uri = uri
      @subclasses = []
      @superclasses = []
    end
    
    # Add the given class as a subclass
    def add_subclass(klass) 
      self.subclasses << klass
      klass.superclasses << self
    end
    
    # Add the given class as a superclass
    def add_superclass(klass)
      self.superclasses << klass
      klass.subclasses << self
    end
    
    # Flag this node as "used" (meaning that there are Resources having
    # this class as it's type)
    def flag_used
      @used = true
    end
    
    # Indicates if the node is "used", meaning if any resources have it
    # as it's type
    def used?
      @used
    end
    
    # Used to remove all "unreal superclasses", that are created by inferencing.
    # A superclass is "unreal" if it appears in the path to the root
    def weed_superclasses(root_path = [])
      superclasses.reject! do |sup|
        reject = false
        # Ignore the last element in the root path, wich points to the direct parent
        if(reject = root_path[0..-2].include?(sup))
          sup.subclasses.reject! { |cl| cl == self }
        end
        reject
      end
      # Clone the subclasses as some will be removed by the recursive calls
      full_subclasses = subclasses.clone
      full_subclasses.each { |sub| sub.weed_superclasses(root_path + [ self ]) }
    end
    
    def uri
      @uri
    end
    
    def to_s
      @uri
    end
    
    def to_uri
      return N::SourceClass.new(@uri)
    end
    
    def inspect
      "<#{self.class.name}:#{self.object_id} @uri=\"#{uri}\" @subclasses = [#{subclasses.collect { |s| s.to_s}.join(', ')}] @superclasses = [#{superclasses.collect { |s| s.to_s}.join(', ')}] >"
    end
    
  end
  
end