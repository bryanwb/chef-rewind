
require 'spec_helper'
require 'chef/rewind'

describe Chef::Provider do

  before(:each) do
    @cookbook_repo_path =  File.join(CHEF_SPEC_DATA, 'cookbooks')
    @cookbook_collection = Chef::CookbookCollection.new(Chef::CookbookLoader.new(@cookbook_repo_path))
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, @cookbook_collection, @events)
    @resource = Chef::Resource.new("funk", @run_context)
    @provider = Chef::Provider.new(@resource, @run_context)
  end


  describe "rewind" do
    it "rewind an existing resource rather than create a new one" do

      @provider.zen_master "foobar" do
        peace false
      end

      @provider.rewind "zen_master[foobar]" do
        peace true
      end
      resources = @run_context.resource_collection.all_resources
      resources.length.should == 1
    end

    it "change the value of an existing resource" do
      @provider.zen_master "foobar" do
        peace false
      end

      @provider.rewind "zen_master[foobar]" do
        peace true
      end

      zen_master = @run_context.resource_collection.find("zen_master[foobar]")
      peace_status = zen_master.instance_exec { @peace }
      peace_status.should == true
    end

    it "throw an error when rewinding a nonexistent resource" do
      lambda do
        @provider.rewind "zen_master[foobar]" do
          peace true
        end
      end.should raise_error(Chef::Exceptions::ResourceNotFound)
    end

    it "returns the resource" do

      original_resource = @provider.zen_master "foobar" do
        peace false
      end

      rewinded_resource = @provider.rewind "zen_master[foobar]" do
        peace true
      end

      rewinded_resource.should == original_resource
    end
  end

end

