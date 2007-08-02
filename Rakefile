require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'

# Runs the test suite
Rake::TestTask.new do |task|
  task.test_files = FileList["test/*test.rb"]
end

# Packages the gem
gem_spec = Gem::Specification.new do |spec|
  spec.name = "semantic_naming"
  spec.version = "0.0.1"
  spec.author = "Daniel Hahn"
  spec.email = "dhahn@gmx.de"
  spec.homepage = "http://talia.discovery-project.eu/"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Semantic Naming Extensions for Talia and others"
  spec.files = FileList["{lib}/**/*"].to_a
  spec.require_path = "lib"
  spec.test_files = FileList["{test}/**/*test.rb"].to_a
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_tar = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include("lib/**/*rb")
end

task :cruise => ['test', 'rdoc']
