# modeled closely after
# https://github.com/opscode/chef/blob/master/lib/chef/dsl/recipe.rb
# and https://github.com/opscode/chef/blob/master/lib/chef/recipe.rb

class Chef
  class Recipe

    #  edits an existing resource if it exists,
    #  otherwise raises the Chef::Exceptions::ResourceNotFound exception
    #  For example:
    #      #  recipe postgresql::server defines user "postgres"  and
    #      #  sets the home directory to /var/pgsql/9.2
    #      include_recipe "postgresql::user"
    #
    #      edit "user[postgres]" do
    #          home "/home/postgres"
    #      end
    # === Parameters
    # resource<String>:: String identifier for resource
    # block<Proc>:: Block with attributes to edit or create
    def edit(resource_id, &block)
      begin
        r = resources(resource_id)  
        Chef::Log.info "Resource #{resource_id} found, now editing it"
        r.instance_exec(&block) if block
      rescue Chef::Exceptions::ResourceNotFound => e
        Chef::Log.info "Resource #{resource_id} not found, so edit fails"
        raise e
      end
    end
  end
end

