require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# Runs the test suite
Rake::TestTask.new do |task|
  task.test_files = FileList["test/*test.rb"]
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include("lib/**/*rb")
  rdoc.title    = 'Semantic Naming'
  rdoc.options << '--line-numbers' << '--inline-source'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "semantic_naming"
    s.author = "Daniel Hahn"
    s.email = "hahn@netseven.it"
    s.homepage = "http://talia.discovery-project.eu/"
    s.platform = Gem::Platform::RUBY
    s.summary = "Semantic Naming Extensions for ActiveRDF, Talia and others"
    s.files = FileList["{lib}/**/*"]
    s.require_path = "lib"
    s.test_files = FileList["{test}/**/*test.rb"]
    s.extra_rdoc_files = ["README.rdoc"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler or dependency not available. Install with: gem install jeweler"
end

begin 
  require 'gokdok'
  Gokdok::Dokker.new do |gd|
    gd.remote_path = ''
  end
rescue LoadError
  puts "Gokdok or dependency not available. Install with: gem install gokdok"
end


task :cruise => ['test', 'rdoc']
