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
  end
end
