namespace :ow do

  require 'momentum/opsworks'
  require 'momentum/tasks'

  desc "Open a web server log tail on the given remote OpsWorks instance (uses AWS_USER as SSH username)."
  task :logs, [:to, :instance, :log_path, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    get_logs(args[:to],args[:instance],args[:log_path],args[:aws_id], args[:aws_secret])
  end

  namespace :logs do
    desc "Open a web server log tail on the given remote OpsWorks instance (uses AWS_USER as SSH username). Uses log_directories hash to find the named log file."
    task :named, [:to, :instance, :key_name, :aws_id, :aws_secret] do |t, args|
      require_credentials!(args)
      key = args[:key_name].to_sym
      if Momentum.log_files.key?(key)
        get_logs(args[:to],args[:instance], Momentum.log_files[key],args[:aws_id], args[:aws_secret])
      else
        $stderr.puts "Invalid named key. Check log_directories hash in momentum.rb"
      end
    end
  end

  def get_logs(to, instance, log_path, aws_id, aws_secret)
    ow = Momentum::OpsWorks.client(aws_id, aws_secret)
    name = stack_name(to)
    stack = Momentum::OpsWorks.get_stack(ow, name)
    instance = Momentum::OpsWorks.get_online_instances(ow, stack_id: stack[:stack_id]).detect{|i| i[:hostname] == instance }
    endpoint = Momentum::OpsWorks.get_instance_endpoint(instance)
    raise "Online instance #{instance} not found for #{name} stack!" unless endpoint

    $stderr.puts "Starting tail -f remotely... (use Ctrl-D to exit cleanly)"
    command = "'sudo su deploy -c \"tail -f #{log_path}\"'"
    sh Momentum::OpsWorks.ssh_command_to(endpoint,command)
  end

end
