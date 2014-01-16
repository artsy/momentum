require "momentum/version"
require 'momentum/railtie' if defined?(::Rails)

module Momentum

  DEFAULT_CONFIG = {
    cookbooks_install_path: 'tmp/cookbooks',
    custom_cookbooks_bucket: 'artsy-cookbooks',
    rails_console_layer: 'rails-app',
    app_layers: ['rails-app']
  }

  def self.config
    @@config ||= DEFAULT_CONFIG.dup
  end

  def self.configure(&block)
    yield self.config
  end

end
