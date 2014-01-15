module Momentum::OpsWorks

  def self.client(aws_id, aws_secret)
    raise "You must specify aws_id and aws_secret!" unless aws_id.present? && aws_secret.present?
    require 'aws-sdk'
    AWS::OpsWorks::Client.new(access_key_id: aws_id, secret_access_key: aws_secret)
  end

  def self.get_stack(client, stack_name)
    client.describe_stacks[:stacks].detect { |k, v| k[:name] == stack_name }.tap do |stack|
      raise "No #{stack_name} stack found!" unless stack
    end
  end

  def self.get_app(client, stack, app_name)
    client.describe_apps(stack_id: stack[:stack_id])[:apps].detect { |a| a[:name] == app_name }
  end

  def self.get_layers(client, stack, layer_names)
    client.describe_layers(stack_id: stack[:stack_id])[:layers].select { |l| layer_names.include?(l[:shortname]) }
  end

  def self.get_online_instance_ids(client, query = {})
    get_online_instances(client, query).map { |i| i[:instance_id] }
  end

  def self.get_online_instances(client, query = {})
    client.describe_instances(query)[:instances].select { |i| i[:status] == 'online' }
  end

  class Config

    def self.from_stack(client, stack_name, app_name = Momentum.config[:app_base_name])
      @@configs ||= {}
      @@configs[[stack_name, app_name]] ||= load_from_stack(client, stack_name, app_name)
    end

    private

    def self.load_from_stack(client, stack_name, app_name)
      stack = Momentum::OpsWorks.get_stack(client, stack_name)
      JSON.parse(stack[:custom_json])["custom_env"][app_name].tap do |config|
        # Custom config from OpsWorks doesn't include RAILS_ENV, so add it.
        config['RAILS_ENV'] = Momentum::OpsWorks.get_app(client, stack, app_name)[:attributes]['RailsEnv']
      end
    end

  end

end
