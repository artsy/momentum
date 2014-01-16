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


  class Deployer
    TIMEOUT = 15 * 60  # wait up to 15 minutes

    def initialize(aws_id, aws_secret)
      @ow = Momentum::OpsWorks.client(aws_id, aws_secret)
    end

    def deploy!(stack_name, app_name = Momentum.config[:app_base_name])
      stack = Momentum::OpsWorks.get_stack(@ow, stack_name)
      app = Momentum::OpsWorks.get_app(@ow, stack, app_name)
      layers = Momentum::OpsWorks.get_layers(@ow, stack, Momentum.config[:app_layers])
      instance_ids = layers.inject([]) { |ids, l| ids + Momentum::OpsWorks.get_online_instance_ids(@ow, layer_id: l[:layer_id]) }
      raise 'No online instances found!' if instance_ids.empty?
      @ow.create_deployment(
        stack_id: stack[:stack_id],
        app_id: app[:app_id],
        command: { name: 'deploy' },
        instance_ids: instance_ids
      )
    end

    def wait_for_success!(deployment, timeout = TIMEOUT)
      Timeout.timeout(timeout) do
        status = @ow.describe_deployments(deployment_ids: [deployment[:deployment_id]])[:deployments].first[:status]
        $stderr.puts 'Polling deploy status...'
        while status == 'running'
          sleep 10
          status = @ow.describe_deployments(deployment_ids: [deployment[:deployment_id]])[:deployments].first[:status]
          $stderr.print '.'
        end
        raise "Deploy failed (status: #{status})!" unless status == 'successful'
      end
      $stderr.puts 'Success!'
    rescue Timeout::Error
      raise "Timed out waiting for deploy to succeed after #{timeout} seconds."
    end
  end

end
