require "momentum/version"
require 'momentum/railtie' if defined?(::Rails)

module Momentum

  DEFAULT_CONFIG = {
    # app_base_name: ...,  # required
    cookbooks_install_path: 'tmp/cookbooks',
    custom_cookbooks_bucket: 'artsy-cookbooks',
    rails_console_layer: 'rails-app',
    app_layers: ['rails-app']
  }

  LOG_FILES = {
    # mysql :,
    # workers :,
    access: '/var/log/apache2/myapp-access.log',
    error: '/var/log/apache2/myapp-error.log',
    ssl_access: '/var/log/apache2/myapp-ssl-access.log',
    ssl_error: '/var/log/apache2/myapp-ssl-error.log'    
  }

  def self.config
    @@config ||= DEFAULT_CONFIG.dup
  end

  def self.configure(&block)
    yield self.config
  end

  def self.log_files
    @@log_files ||= LOG_FILES.dup
  end

  def self.configure_logs(&block)
    yield self.log_files
  end
end
