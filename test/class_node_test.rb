require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
# Test the uri class
class URITest < Test::Unit::TestCase

  def test_flagging
    node = OntologyGraph::ClassNode.new('test_flagging')
    assert(!node.used?)
    node.flag_used
    assert(node.used?)
  end

end