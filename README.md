# Chef::Edit

This adds a simple function to the Chef library scope to
edit and existing resource. If the given resource does not exist, 
a new resource will be created.

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

# file my-postgresql/recipes/
require 'chef/edit'

include_recipe "postgresql::server"

edit "user[postgres]"
  home '/var/lib/pgsql/9.2'
end

```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
