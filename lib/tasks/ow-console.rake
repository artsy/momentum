namespace :ow do

  require 'momentum/opsworks'
  require 'momentum/tasks'

  desc "Open a Rails console on the given remote OpsWorks stack (uses AWS_USER as SSH username or falls back to local username)."
  task :console, [:to, :env, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
    name = stack_name(args[:to])
    stack = Momentum::OpsWorks.get_stack(ow, name)
    layer = ow.describe_layers(stack_id: stack[:stack_id])[:layers].detect { |l| l[:shortname] == Momentum.config[:rails_console_layer] }
    raise "No '#{Momentum.config[:rails_console_layer]}' layer found for #{name} stack!" unless layer
    instance = Momentum::OpsWorks.get_online_instances(ow, layer_id: layer[:layer_id]).sample
    raise "No '#{Momentum.config[:rails_console_layer]}' instances found for #{name} stack!" unless instance
    endpoint = Momentum::OpsWorks.get_instance_endpoint(instance)
    raise "No online '#{Momentum.config[:rails_console_layer]}' instances found for #{name} stack!" unless endpoint

    env = ARGV.grep(/^(\w+)=(.*)$/m)
    env << "PATH=$PATH:#{Momentum.config[:append_path]}"
    env << "RAILS_ENV=#{args[:env] || args[:to]}"
    env << "RUBYOPT=-EUTF-8"

    $stderr.puts "Starting remote console... (use Ctrl-D to exit cleanly)"
    command = "'sudo su deploy -c \"cd #{Momentum.config[:deploy_root]}/#{Momentum.config[:app_base_name]}/current && env #{env.join(" ")} bundle exec rails console\"'"
    sh Momentum::OpsWorks.ssh_command_to(endpoint,command)
  end

end
