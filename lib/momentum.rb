require "momentum/version"
require 'momentum/railtie' if defined?(::Rails)

module Momentum

  DEFAULT_CONFIG = {
    # app_base_name: ...,  # required
    cookbooks_install_path: 'tmp/cookbooks.tgz',
    custom_cookbooks_bucket: 'artsy-cookbooks',
    rails_console_layer: 'rails-app',
    app_layers: ['rails-app'],
    logs_root: '/var/log/apache2/'
  }

  def self.config
    @@config ||= DEFAULT_CONFIG.dup
  end

  def self.configure(&block)
    yield self.config
  end

end
