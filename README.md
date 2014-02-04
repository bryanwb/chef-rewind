# Chef::Rewind

This adds a simple function to the Chef library scope to
rewind or unwind an existing resource. If the given resource does not exist, 
a `Chef::Exceptions::ResourceNotFound` exception will be raised.

These functions are designed to assist the library cookbook pattern.

Effectively, rewind/unwind resource allows you to monkeypatch a cookbook that you would rather not modify directly. It will modify some properties of a resource, during the complile phase, before chef-client actually starts the run phase.

## Installation

Add this line to your application's Gemfile:

    gem 'chef-rewind'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chef-rewind

## Usage

### rewind

```Ruby
# file postgresql/recipes/server.rb
user "postgres" do
  uid  26
  home '/home/postgres'
  supports  :manage_home => true
end

# file my-postgresql/recipes/server.rb
chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "postgresql::server"

rewind "user[postgres]" do
  home '/var/lib/pgsql/9.2'
end

```

The user `postgres` will act once with the home directory
`/var/lib/pgsql/9.2` and the `cookbook` attribute is now
`my-postgresql` instead of `postgresql`. This last part is
particularly important for templates and cookbook files.

### unwind

```Ruby
# file postgresql/recipes/server.rb
user "postgres" do
  uid  26
  home '/home/postgres'
  supports  :manage_home => true
end

# file my-postgresql/recipes/server.rb
chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "postgresql::server"

unwind "user[postgres]"

```

This will completely remove the resource. It is useful
for resources that are impossible to change correctly.
Resource notifications, for example,
can't be overwritten by `rewind`, only appended.

So if you need to change notifications of a resource,
you need to `unwind` and redefine the resource. Example:

```Ruby
# file cookbook-elasticsearch/recipes/default.rb
template "logging.yml" do
  path "#{node.elasticsearch[:path][:conf]}/logging.yml"
  source "logging.yml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755

  notifies :restart, 'service[elasticsearch]'
end

# file my-elasticsearch/recipes/default.rb
chef_gem "chef-rewind"
require 'chef/rewind'

unwind "template[logging.yml]"

template "logging.yml" do
  path  "#{node.elasticsearch[:path][:conf]}/logging.yml"
  source "logging.yml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
  cookbook "elasticsearch"

  # this is the only change from original definition
  notifies :run, 'execute[Custom ElasticSearch restarter]'
end

```

This allows you to define your own ElasticSearch restart script.
It's impossible to `rewind` notifications,
thus you need to `unwind` and redefine it based on the original version.



## Gotchas *Important*

The rewind method does not automatically change the `cookbook`
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
chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "postgresql::server"
# my-postgresql.conf.erb located inside my-postgresql/templates/default/my-postgresql.conf.erb
rewind :template => "/var/pgsql/data/postgresql.conf" do
  source "my-postgresql.conf.erb"
  cookbook "my-postgresql"
end

```

If you do not specify `cookbook` the rewind function will likely
return an error since Chef will look in the postgresql cookbook for
the source file and not in the my-postgresql cookbook.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
