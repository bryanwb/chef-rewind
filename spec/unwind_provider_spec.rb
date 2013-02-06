require 'spec_helper'
require 'chef/rewind'

describe Chef::Provider do

  before(:each) do
    @cookbook_repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "data", "cookbooks"))
    cl = Chef::CookbookLoader.new(@cookbook_repo)
    cl.load_cookbooks
    @cookbook_collection = Chef::CookbookCollection.new(cl)
    @node = Chef::Node.new
    @node.name "latte"
    @node.automatic[:platform] = "mac_os_x"
    @node.automatic[:platform_version] = "10.5.1"
    @node.normal[:tags] = Array.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, @cookbook_collection, @events)
    @resource = Chef::Resource.new("funk", @run_context)
    @provider = Chef::Provider.new(@resource, @run_context)
    @runner = Chef::Runner.new(@run_context)
  end


  describe "unwind" do
    it "should remove resource when unwind is called" do
      @provider.zen_master "foobar" do
        peace false
      end

      @provider.unwind "zen_master[foobar]"

      resources = @run_context.resource_collection.all_resources
      resources.length.should == 0
    end

    it "should define resource completely when unwind is called" do
      @provider.zen_master "foo" do
        action :nothing
        peace false
      end
      @provider.cat "blanket" do
      end
      @provider.zen_master "bar" do
        action :nothing
        peace false
      end

      @provider.unwind "zen_master[foo]"

      @provider.zen_master "foobar" do
        peace true
        action :change
        notifies :blowup, "cat[blanket]"
      end

      lambda { @runner.converge }.should raise_error(Chef::Provider::Cat::CatError)
    end

    it "should throw an error when unwinding a nonexistent resource" do
      lambda do
        @provider.unwind "zen_master[foobar]"
      end.should raise_error(Chef::Exceptions::ResourceNotFound)
    end
  end

end

