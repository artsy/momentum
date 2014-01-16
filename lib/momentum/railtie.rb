class Momentum::Railtie < ::Rails::Railtie

  railtie_name :momentum

  rake_tasks do
    load 'tasks/init.rake'
    load 'tasks/ow-config.rake'
    load 'tasks/ow-cookbooks.rake'
  end

end
