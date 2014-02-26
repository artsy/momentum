namespace :ow do

  require 'momentum/tasks'

  namespace :deploy do
    %w{staging production}.each do |env|
      desc "Deploy the #{Momentum.config[:app_base_name]} to the #{stack_name(env)} OpsWorks stack."
      task(env.to_sym) { Rake::Task['ow:deploy'].invoke(env) }
    end
  end

  desc "Deploy to the given OpsWorks stack."
  task :deploy, [:to, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    deployer = Momentum::OpsWorks::Deployer.new(args[:aws_id], args[:aws_secret])
    name = stack_name(args[:to])
    deployment = deployer.deploy!(name, false)
    $stderr.puts "Triggered deployment #{deployment[:deployment_id]} to #{name}..."
    deployer.wait_for_success!(deployment)
  end

  namespace :deploy do
    desc "Deploy to the given OpsWorks stack and tigger database migrations."
    task :migrations, [:to, :aws_id, :aws_secret] do |t, args|
      require_credentials!(args)
      deployer = Momentum::OpsWorks::Deployer.new(args[:aws_id], args[:aws_secret])
      name = stack_name(args[:to])
      deployment = deployer.deploy!(name, true)
      $stderr.puts "Triggered deployment #{deployment[:deployment_id]} and database migrations to #{name}..."
      deployer.wait_for_success!(deployment)
    end
  end
end
