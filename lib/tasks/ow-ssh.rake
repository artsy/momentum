namespace :ow do

  require 'momentum/opsworks'
  require 'momentum/tasks'

  desc "Starts SSH session on a remote OpsWorks instance, as specified by layer or instance name."
  task :ssh, [:to, :layer_or_instance, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
    name = stack_name(args[:to])
    stack = Momentum::OpsWorks.get_stack(ow, name)
    layer = ow.describe_layers(stack_id: stack[:stack_id])[:layers].detect { |l| l[:shortname] == args[:layer_or_instance] }
    instance = if layer
      Momentum::OpsWorks.get_online_instances(ow, layer_id: layer[:layer_id]).sample
    else
      Momentum::OpsWorks.get_online_instances(ow, stack_id: stack[:stack_id]).detect { |i| i[:hostname] == args[:layer_or_instance] }
    end
    raise "No online instances matching #{args[:layer_or_instance].inspect} were found!" unless instance
    endpoint = Momentum::OpsWorks.get_instance_endpoint(instance)

    $stderr.puts "Starting SSH... (use Ctrl-D to exit cleanly)"
    sh Momentum::OpsWorks.ssh_command_to(endpoint)
  end

end
