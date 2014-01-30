namespace :ow do

  require 'momentum/opsworks'
  require 'momentum/tasks'

  desc "Open a web server log tail on the given remote OpsWorks stack (uses AWS_USER as SSH username)."
  task :logs, [:to, :log_type, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
    name = stack_name(args[:to])
    stack = Momentum::OpsWorks.get_stack(ow, name)
    layer = ow.describe_layers(stack_id: stack[:stack_id])[:layers].detect { |l| l[:shortname] == 'rails-app' }
    instance = Momentum::OpsWorks.get_online_instances(ow, layer_id: layer[:layer_id]).sample
    endpoint = Momentum::OpsWorks.get_instance_endpoint(instance)
    raise "No online rails-app instances found for #{name} stack!" unless endpoint

    $stderr.puts "Starting tail -f remotely... (use Ctrl-D to exit cleanly)"
    command = "'sudo su deploy -c \"tail -f #{Momentum.config[:logs_root]}#{Momentum.config[:app_base_name]}-#{args[:log_type] || 'ssl-error'}.log\"'"
    sh Momentum::OpsWorks.ssh_command_to(endpoint,command)
  end

end
