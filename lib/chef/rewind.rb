# modeled closely after
# https://github.com/opscode/chef/blob/master/lib/chef/dsl/recipe.rb
# and https://github.com/opscode/chef/blob/master/lib/chef/recipe.rb

class Chef
  class Recipe

    #  rewinds an existing resource if it exists,
    #  otherwise raises the Chef::Exceptions::ResourceNotFound exception
    #  For example:
    #      #  recipe postgresql::server defines user "postgres"  and
    #      #  sets the home directory to /var/pgsql/9.2
    #      include_recipe "postgresql::user"
    #
    #      rewind "user[postgres]" do
    #          home "/home/postgres"
    #      end
    # === Parameters
    # resource<String>:: String identifier for resource
    # block<Proc>:: Block with attributes to rewind or create
    def rewind(resource_id,  &block)
      begin
        r = resources(resource_id)
        Chef::Log.info "Resource #{resource_id} found, now rewinding it"
        r.instance_exec(&block) if block
      rescue Chef::Exceptions::ResourceNotFound => e
        Chef::Log.info "Resource #{resource_id} not found, so rewind fails"
        raise e
      end
    end
  end
end


class Chef
  class Resource
    def cookbook_name(arg=nil)
      set_or_return(
                    :cookbook_name,
                    arg,
                    :kind_of => String)
    end

    def recipe_name(arg=nil)
      set_or_return(
                    :recipe_name,
                    arg,
                    :kind_of => String)
    end
  end
end
