module N
  class Namespace < N::URI
    @@default_namespaces = {
      'rdf' => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      'xsd' => "http://www.w3.org/2001/XMLSchema#",
      'rdfs' => "http://www.w3.org/2000/01/rdf-schema#",
      'owl' => "http://www.w3.org/2002/07/owl#"
    }
  end
end
