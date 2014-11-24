require 'spec_helper'
require 'chef/rewind'

describe Chef::Recipe do

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
    @recipe = Chef::Recipe.new("hjk", "test", @run_context)
    @runner = Chef::Runner.new(@run_context)
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

    it "should delete resource completely when unwind is called" do
      @recipe.zen_master "foo" do
        action :nothing
        peace false
      end
      @recipe.cat "blanket" do
      end
      @recipe.zen_master "bar" do
        action :nothing
        peace false
      end

      @recipe.unwind "zen_master[foo]"

      @recipe.zen_master "foobar" do
        peace true
        action :change
        notifies :blowup, "cat[blanket]"
      end

      lambda { @runner.converge }.should raise_error(Chef::Provider::Cat::CatError)
    end

    it "should throw an error when unwinding a nonexistent resource" do
      lambda do
        @recipe.unwind "zen_master[foobar]"
      end.should raise_error(Chef::Exceptions::ResourceNotFound)
    end

    it "should correctly unwind a resource that was defined more than once" do
      @recipe.zen_master "foo" do
        peace true
      end
      @recipe.cat "blanket"
      @recipe.zen_master "foo" do
        peace false
      end
      @recipe.zen_master "bar"

      @recipe.unwind "zen_master[foo]"

      %w(zen_master[bar] cat[blanket]).each do |name|
        resource = @run_context.resource_collection.lookup(name)
        resource.to_s.should == name
      end
    end
  end

end
