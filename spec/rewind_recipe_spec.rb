
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

    # Shell/ext.rb is on the run path, and it defines
    # Chef::Recipe#resources to call pp, which we don't want when
    # we're running tests.
    @recipe.stub!(:pp)
  end


  describe "rewind" do
    it "rewind an existing resource rather than create a new one" do

      @recipe.zen_master "foobar" do
        peace false
      end
      
      @recipe.rewind "zen_master[foobar]" do
        peace true
      end
      resources = @run_context.resource_collection.all_resources
      resources.length.should == 1
    end

    it "change the value of an existing resource" do
      @recipe.zen_master "foobar" do
        peace false
      end
      
      @recipe.rewind "zen_master[foobar]" do
        peace true
      end
      
      zen_master = @run_context.resource_collection.find("zen_master[foobar]")
      peace_status = zen_master.instance_exec { @peace }
      peace_status.should == true 
    end
    
    it "throw an error when rewinding a nonexistent resource" do
      lambda do 
        @recipe.rewind "zen_master[foobar]" do
          peace true
        end
      end.should raise_error(Chef::Exceptions::ResourceNotFound)
    end
  end

end
