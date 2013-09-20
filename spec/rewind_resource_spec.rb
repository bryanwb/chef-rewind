require 'spec_helper'
require 'chef/rewind'

class ResourceTestHarness < Chef::Resource
  provider_base Chef::Provider::Package
end

describe Chef::Resource do
  before(:each) do
    @cookbook_repo_path =  File.join(CHEF_SPEC_DATA, 'cookbooks')
    @cookbook_collection = Chef::CookbookCollection.new(Chef::CookbookLoader.new(@cookbook_repo_path))
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, @cookbook_collection, @events)
    @resource = Chef::Resource.new("funk", @run_context)
  end

  describe "cookbook_name" do
    it "cookbook_name sets @cookbook_name properly" do
      @resource.cookbook_name "foobar"
      @resource.cookbook_name.should == "foobar"
    end

  end

  describe "recipe_name" do
    it "recipe_name sets @recipe_name properly" do
      @resource.recipe_name "foobar"
      @resource.recipe_name.should == "foobar"
    end

  end

end
