require File.dirname(__FILE__) + "/../lib/semantic_naming"
begin
  require 'rubygems'
  $: << File.join(File.dirname(__FILE__), '..', '..', 'ActiveRDF', 'lib')
  require 'active_rdf'
  
  adapter_found = true
  if(ConnectionPool.adapter_types.include?(:sesame))
    ConnectionPool.add(:type => :sesame, :location => 'test_sesame')
    puts "Running tests with Sesame adapter."
  elsif(ConnectionPool.adapter_types.include?(:redland))
    ConnectionPool.add(:type => :redland, :location => 'hashes', :name => :test, :"hash-type" => :memory)
    puts "Running tests with Redland adapter."
  elsif(ConnectionPool.adapter_types.include?(:rdflite))
    ConnectionPool.add(:type => :rdflite)
    puts "Running tests with RDFLite adapter. Some may fail"
  else
    $stderr.puts "No suitable ActiveRDF adapter found. tests will not run."
    adapter_found = false
  end
  
  RDF_ACTIVE = adapter_found
rescue Exception => e
  RDF_ACTIVE = false
  $stderr.puts "Not running rdf-tests: ActiveRDF could not be loaded: #{e.message}"
end

# Check for the tesly adapter, and load it if it's there
if(File.exists?(File.dirname(__FILE__) + '/tesly_reporter.rb'))
  printf("Continuing with tesly \n")
  require File.dirname(__FILE__) + '/tesly_reporter'
end

N::Namespace.shortcut(:rdftest, 'http://rdftestdummy/')
N::Namespace.shortcut(:rdftest2, 'http://rdftestdummy2/')

if(RDF_ACTIVE)
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

