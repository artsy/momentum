namespace :ow do

  require 'momentum/tasks'

  namespace :execute_recipe do
    %w{staging production}.each do |env|
      desc "Execute recipe on #{Momentum.config[:app_base_name]} in the #{stack_name(env)} OpsWorks stack."
      task(env.to_sym) { Rake::Task['ow:execute_recipe'].invoke(env) }
    end
  end

  desc "Execute a recipe on the given OpsWorks stack."
  task :execute_recipe, [:to, :layer, :recipe, :aws_id, :aws_secret] do |t, args|
    require_credentials!(args)
    deployer = Momentum::OpsWorks::Deployer.new(args[:aws_id], args[:aws_secret])
    name = stack_name(args[:to])
    recipe = args[:recipe]
    layer = args[:layer] if args[:layer] && !args[:layer].empty?
    recipe_runner = deployer.execute_recipe!(name, layer, recipe)
    $stderr.puts "Applying #{recipe} #{recipe_runner[:deployment_id]} to #{[name, layer].compact.join(', ')}..."
    deployer.wait_for_success!(recipe_runner)
  end
end
