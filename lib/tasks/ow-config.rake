namespace :ow do

  require 'momentum/tasks'

  desc "Print current configuration values for given stack."
  task :config, [:to, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
    Momentum::OpsWorks::Config.from_stack(ow, stack_name(args[:to])).each do |k, v|
      puts "#{k}: #{v}"
    end
  end

  namespace :config do
    desc "Set configuration values from OpsWorks on the current environment. Can be chained to other tasks that need the ENV."
    task :from_env, [:to, :aws_id, :aws_secret] do |t, args|
      require_credentials!(args)
      ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
      Momentum::OpsWorks::Config.from_stack(ow, stack_name(args[:to])).each do |k, v|
        ENV[k] = v.to_s
      end
      @ow_config_from_env = true  # allow chained tasks to raise an error unless this is set
    end
  end

end
