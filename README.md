# Momentum

Shared utilities for managing and deploying OpsWorks apps at Artsy.


## Installation

Add this line to your application's Gemfile, probably in the `:development` group:

    gem 'momentum', require: false

In your application's Rakefile, add this line above the `load_tasks` command:

    begin
      require 'momentum'  # necessary b/c tasks from gems in :development group aren't loaded automatically
      Momentum.configure do |conf|
        conf[:app_base_name] = 'your_app_name'
      end
    rescue LoadError
      # momentum should only be installed in development
    end

If you arent's using Rails / don't have access to the `load_tasks` command, you can load all rake tasks by adding `require 'momentum/rake'` to your project's Rakefile.

Finally, execute:

    $ bundle


## Berkshelf

Momentum uses [Berkshelf](http://berkshelf.com/) to package application cookbooks and expects a `Berksfile` present in the top-level of your project.

## Naming

It's assumed that stacks are named with an app name and modifier, such as _todo-production_. The modifier is usually an environment, but might also be a developer name or some other label, such _todo-joey_.

## Rake Tasks

This gem adds a few useful rake tasks to your project. By default, the `aws_id` and `aws_secret` arguments are taken from `AWS_ID` and `AWS_SECRET` ENV variables. The `to` argument refers to the modifier mentioned above (e.g., _production_). It's appended to the configured `app_base_name` to form the stack name.

### ow:config[to,aws_id,aws_secret]

Print the custom configuration values for the given stack. E.g.:

    bundle exec rake ow:config[joey]

### ow:config:from_env[to,aws_id,aws_secret]

Add the given stack's custom configuration values to the current task's ENV. Can be prepended to other rake tasks that depend on the ENV, e.g.:

    bundle exec rake ow:config:from_env[production] some:migration

### ow:console[to,env,aws_id,aws_secret]

Start a rails console on the given remote OpsWorks stack. Chooses an instance of the _rails_ layer by default, or the configured `rails_console_layer` if provided. E.g.:

    bundle exec rake ow:console[production]

For stacks with labels not matching the Rails environment (e.g., _reflection-joey_), provide a 2nd argument with the desired environment:

    bundle exec rake ow:console[joey,staging]

### ow:cookbooks:update[to,aws_id,aws_secret]

Package, upload, and propagate custom cookbooks to the given stack. Or, more concisely:

    bundle exec rake ow:cookbooks:update[staging]
    # or just:
    bundle exec rake ow:cookbooks:update:staging

### ow:deploy[to,aws_id,aws_secret]

Trigger an OpsWorks deploy to the given stack. By default, deploys app to all running instances of the _rails_ layer, or the list configured in `app_layers`. E.g.:

    bundle exec rake ow:deploy[staging]
    # or just:
    bundle exec rake ow:deploy:staging

### ow:logs[to,instance,log_path,aws_id,aws_secret]

Execute a tail -f (follow) command against a remote log path on the given remote OpsWorks instance and stack. The path may include wildcards. E.g.:

    bundle exec rake ow:logs[staging,rails1,/home/deploy/myapp/shared/log/staging.log]

### ow:ssh[to,layer_or_instance,aws_id,aws_secret]

SSH to an OpsWorks instance. If the `layer_or_instance` argument is a layer, an online instance is chosen randomly from the layer. Otherwise, the name of an online instance is expected. E.g.:

    bundle exec rake ow:ssh[staging,memcached]
    # or...
    bundle exec rake ow:ssh[staging,rails1]

### ow:execute_recipe[to,layer,recipe,aws_id,aws_secret]

Execute a Chef recipe on the given layer in the given stack. By default, will execute recipes on all running instances of the _rails_ layer, or the list configured in `app_layers`. E.g.:

    bundle exec rake ow:execute_recipe[staging,rails,restart_unicorns]
    # Assuming 'restart_unicorns' is a valid Chef recipe.


## Configuration:

* **app_base_name** - Your app's name. Stacks are assumed to be named like _appbasename-env_ (e.g., _gravity-staging_ or _reflection-joey_).
* **app_layers** - Array of OpsWorks layer names to which this rails app should be deployed. Default: `['rails']`
* **cookbooks_install_path** - Local path where berkshelf will install cookbooks. Default: _tmp/cookbooks.tgz_
* **custom_cookbooks_bucket** - Bucket to which custom cookbooks are uploaded. Default: _artsy-cookbooks_
* **rails_console_layer** - The OpsWorks layer used for SSH-ing and starting a rails console. Default: _rails_


## To Do

* git/branch helpers
* Tests


&copy; 2014-2016 [Artsy](http://artsy.net). See [LICENSE](LICENSE.txt) for details.

