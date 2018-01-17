require "momentum/version"
require 'momentum/railtie' if defined?(::Rails)

module Momentum

  DEFAULT_CONFIG = {
    # app_base_name: ...,  # required
    stack_base_name: nil,
    cookbooks_install_path: 'tmp/cookbooks.tgz',
    custom_cookbooks_bucket: 'artsy-cookbooks',
    rails_console_layer: 'rails',
    app_layers: ['rails'],
    logs_root: '/var/log/nginx/',
    deploy_root: '/home/deploy',
    append_path: ''
  }

  def self.config
    @@config ||= DEFAULT_CONFIG.dup
  end

  def self.configure(&block)
    yield self.config
  end

end
