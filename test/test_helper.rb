require File.dirname(__FILE__) + "/../lib/semantic_naming"
begin
  $: << File.join(File.dirname(__FILE__), '..', '..', 'ActiveRDF', 'lib')
  require 'active_rdf'
  RDF_ACTIVE = true
rescue Exception
  RDF_ACTIVE = false
  $stderr.puts "Not running rdf-tests: ActiveRDF not found."
end

# Check for the tesly adapter, and load it if it's there
if(File.exists?(File.dirname(__FILE__) + '/tesly_reporter.rb'))
  printf("Continuing with tesly \n")
  require File.dirname(__FILE__) + '/tesly_reporter'
end

N::Namespace.shortcut(:rdftest, 'http://rdftestdummy/')
N::Namespace.shortcut(:rdftest2, 'http://rdftestdummy2/')

if(RDF_ACTIVE)
  # ConnectionPool.add(:type => :rdflite)
  ConnectionPool.add(:type => :redland, :location => 'hashes', :name => :test, :"hash-type" => :memory)
  db = ConnectionPool.write_adapter
  db.add(N::RDFTEST.test1, N::RDF::type, N::RDFTEST.Type1)
  db.add(N::RDFTEST.test1, N::RDFS::label, "Like a virgin")
  db.add(N::RDFTEST.test1, N::RDFS::label, "come on@en")
  db.add(N::RDFTEST.test2, N::RDF::type, N::RDFTEST.Type1)
  db.add(N::RDFTEST.test3, N::RDF::type, N::RDFTEST.Type2)
  db.add(N::RDFTEST2.test1, N::RDF::type, N::RDFTEST.Type1)
  db.add(N::RDFTEST2.test2, N::RDF::type, N::RDFTEST.Type1)
  db.add(N::RDFTEST.Type1, N::RDF::type, N::RDFS.Class)
  db.add(N::RDFTEST.Type2, N::RDF::type, N::RDFS.Class)
  db.add(N::RDFTEST.Type3, N::RDF::type, N::RDFS.Class)
  db.add(N::RDFTEST.Type4, N::RDF::type, N::RDFS.Class)
  db.add(N::RDFTEST.Type2, N::RDFS::subClassOf, N::RDFTEST.Type1)
  db.add(N::RDFTEST.Type3, N::RDFS::subClassOf, N::RDFTEST.Type1)
  db.add(N::RDFTEST.Type3, N::RDFS::subClassOf, N::RDFTEST.Type4)
end

