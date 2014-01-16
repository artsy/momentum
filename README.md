# Momentum

Shared utilities for managing and deploying OpsWorks apps at Artsy.


## Installation

Add this line to your application's Gemfile, probably in the `:development` group:

    gem 'momentum'

In your application's Rakefile, add this line above the `load_tasks` command:

    require 'momentum'  # necessary b/c tasks from gems in :development group aren't loaded automatically
    Momentum.configure do |conf|
      conf[:app_base_name] = 'your_app_name'
    end

And then execute:

    $ bundle
    $ bundle exec rake momentum:init


## Rake Tasks

This gem adds a few useful rake tasks to your project. In general, the `aws_id` and `aws_secret` arguments are taken from `AWS_ID` and `AWS_SECRET` ENV variables. The `to` argument can refer to an environment or developer (e.g., _joey_ in the case of _reflection-joey_, or _staging_ in the case of _gravity-staging_). It's assumed that this value can be appended to the `app_base_name` to form the stack name.

### momentum:init

Initialize a default librarian-chef config.

### ow:config[to,aws_id,aws_secret]

Print the custom configuration values for the given stack. E.g.:

    bundle exec rake ow:config[joey]

### ow:config:from_env[to,aws_id,aws_secret]

Add the given stack's custom configuration values to the current task's ENV. Can be prepended to other rake tasks that depend on the ENV, e.g.:

    bundle exec rake ow:config:from_env[production] some:migration

### ow:cookbooks:update[to,aws_id,aws_secret]

Zip, upload, and propagate custom cookbooks to the given stack. Or, more concisely:

    bundle exec rake ow:cookbooks:update[staging]
    # or just:
    bundle exec rake ow:cookbooks:update:staging


## Configuration:

* **app_base_name** - Your app's name. Stacks are assumed to be named like _appbasename-env_ (e.g., _gravity-staging_ or _reflection-joey_).
* **cookbooks_install_path** - Local path where librarian-chef will install cookbooks. Default: _tmp/cookbooks_
* **custom_cookbooks_bucket** - Bucket to which custom cookbooks are uploaded. Default: _artsy-cookbooks_


## To Do

* git/branch helpers
* deploy tasks
* opsworks console tasks
* Integrate librarian-chef as legit dependency once rails/chef conflicts resolved


## Set-up Notes

    $ bundle gem momentum
    $ echo '2.0.0' > momentum/.ruby-version
    $ echo 'momentum' > momentum/.ruby-gemset
    $ cd momentum/
    $ git commit -m"Initial commit - boilerplate gem stuff only"
