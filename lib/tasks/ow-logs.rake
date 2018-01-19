namespace :ow do

  require 'momentum/opsworks'
  require 'momentum/tasks'

  desc "Open a web server log tail on the given remote OpsWorks stack (uses AWS_USER as SSH username)."
  task :logs, [:to, :instance, :log_path, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
    name = stack_name(args[:to])
    stack = Momentum::OpsWorks.get_stack(ow, name)
    instance = Momentum::OpsWorks.get_online_instances(ow, stack_id: stack[:stack_id]).detect{|i| i[:hostname] == args[:instance] }
    raise "Online instance #{args[:instance]} not found for #{name} stack!" unless instance
    endpoint = Momentum::OpsWorks.get_instance_endpoint(instance)

    $stderr.puts "Starting tail -f remotely... (use Ctrl-D to exit cleanly)"
    command = "'sudo su - deploy -c \"tail -f #{args[:log_path]}\"'"
    sh Momentum::OpsWorks.ssh_command_to(endpoint, command)
  end

end
