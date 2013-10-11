require 'spec_helper'
require 'chef/rewind'

describe Chef::Recipe do
  
  before(:each) do
    @cookbook_repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "data", "cookbooks"))
    cl = Chef::CookbookLoader.new(@cookbook_repo)
    cl.load_cookbooks
    @cookbook_collection = Chef::CookbookCollection.new(cl)
    @node = Chef::Node.new
    @node.normal[:tags] = Array.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, @cookbook_collection, @events)
    @recipe = Chef::Recipe.new("hjk", "test", @run_context)
  end


  describe "unwind" do
    it "should remove resource when unwind is called" do
      @recipe.zen_master "foobar" do
        peace false
      end
      
      @recipe.unwind "zen_master[foobar]"

      resources = @run_context.resource_collection.all_resources
      resources.length.should == 0
    end

    it "should throw an error when unwinding a nonexistent resource" do
      lambda do 
        @recipe.unwind "zen_master[foobar]"
      end.should raise_error(Chef::Exceptions::ResourceNotFound)
    end
  end

end
