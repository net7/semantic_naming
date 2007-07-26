# Test helper

# Check for the tesly adapter, and load it if it's there
if(File.exists?(File.dirname(__FILE__) + '/tesly_reporter.rb'))
  printf("Continuing with tesly \n")
  require File.dirname(__FILE__) + '/tesly_reporter'
end