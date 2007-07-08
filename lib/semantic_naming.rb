# SemanticNaming loader

# adding semantic_naming subdirectory to the ruby loadpath
file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))
$: << this_dir
$: << this_dir + '/semantic_naming/'

require 'semantic_naming/uri'
require 'semantic_naming/namespace'
require 'semantic_naming/source_class'
require 'semantic_naming/predicate'
