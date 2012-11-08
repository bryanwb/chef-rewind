# Chef::Edit

This adds a simple function to the Chef library scope to
edit and existing resource. If the given resource does not exist, 
a Chef::Exceptions::ResourceNotFound exception will be raised.

This function is designed to assist the library cookbook pattern.

## Installation

Add this line to your application's Gemfile:

    gem 'chef-edit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chef-edit

## Usage

```Ruby
# file postgresql/recipes/server.rb
user "postgres" do
  uid  26
  home '/home/postgres'
  supports  :manage_home => true
end

# file my-postgresql/recipes/server.rb
chef_gem "chef-edit"
require 'chef/edit'

include_recipe "postgresql::server"

edit "user[postgres]" do
  home '/var/lib/pgsql/9.2'
end

```

The user "postgres" will act once with the home directory
'/var/lib/pgsql/9.2 and the cookbook_name attribute is now
"my-postgresql" instead of "postgresql". This last part is
particularly important for templates and cookbook files.

## Gotchas *Important*

The edit method does not automatically change the cookbook_name
attribute for a resource to the current cookbook. Doing so could cause
some unexpected behavior, particularly for less expert chef users.

Example 

```Ruby
# file postgresql/recipes/server.rb
template "/var/pgsql/data/postgresql.conf" do
  source  "postgresql.conf.erb"
  owner "postgres"
end

# file my-postgresql/recipes/server.rb
chef_gem "chef-edit"
require 'chef/edit'

include_recipe "postgresql::server"
# my-postgresql.conf.erb located inside my-postgresql/templates/default/my-postgresql.conf.erb
edit :template => "/var/pgsql/data/postgresql.conf" do
  source "my-postgresql.conf.erb"
  cookbook_name "my-postgresql"
end

```

If you do not specify cookbook_name the edit function will likely
return an error since Chef will look in the postgresql cookbook for
the source file and not in the my-postgresql cookbook.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
