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

And then execute:

    $ bundle
    $ gem install librarian-chef  # ideally this would be in the bundle, but has conflicts
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

### ow:console[to,env,aws_id,aws_secret]

Start a rails console on the given remote OpsWorks stack. Chooses an instance of the _rails-app_ layer by default, or the configured `rails_console_layer` if provided. E.g.:

    bundle exec rake ow:console[production]

For stacks with labels not matching the Rails environment (e.g., _reflection-joey_), provide a 2nd argument with the desired environment:

    bundle exec rake ow:console[joey,staging]

### ow:cookbooks:update[to,aws_id,aws_secret]

Zip, upload, and propagate custom cookbooks to the given stack. Or, more concisely:

    bundle exec rake ow:cookbooks:update[staging]
    # or just:
    bundle exec rake ow:cookbooks:update:staging

### ow:deploy[to,aws_id,aws_secret]

Trigger an OpsWorks deploy to the given stack. By default, deploys app to all running instances of the _rails-app_ layer, or the list configured in `app_layers`. E.g.:

    bundle exec rake ow:deploy[staging]
    # or just:
    bundle exec rake ow:deploy:staging

### ow:logs[to,instance,log_path,aws_id,aws_secret]

Execute a tail -f (follow) command against an error or access log file on the given remote OpsWorks stack. Default log is 'ssl-error'. Chooses an instance of the _rails-app_ layer. E.g.:

    bundle exec rake ow:logs[staging,rails-app1,/srv/www/myapp/shared/log/staging.log]

The log path may include wildcards.

## Configuration:

* **app_base_name** - Your app's name. Stacks are assumed to be named like _appbasename-env_ (e.g., _gravity-staging_ or _reflection-joey_).
* **app_layers** - Array of OpsWorks layer names to which this rails app should be deployed. Default: `['rails-app']`
* **cookbooks_install_path** - Local path where librarian-chef will install cookbooks. Default: _tmp/cookbooks_
* **custom_cookbooks_bucket** - Bucket to which custom cookbooks are uploaded. Default: _artsy-cookbooks_
* **rails_console_layer** - The OpsWorks layer used for SSH-ing and starting a rails console. Default: _rails-app_


## To Do

* git/branch helpers
* Integrate librarian-chef as legit dependency once rails/chef conflicts resolved
* Tests


&copy; 2014 [Artsy](http://artsy.net). See [LICENSE](LICENSE.txt) for details.

