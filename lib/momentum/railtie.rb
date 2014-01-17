class Momentum::Railtie < ::Rails::Railtie

  railtie_name :momentum

  rake_tasks do
    load 'tasks/init.rake'
    load 'tasks/librarian.rake'
    load 'tasks/ow-config.rake'
    load 'tasks/ow-console.rake'
    load 'tasks/ow-cookbooks.rake'
    load 'tasks/ow-deploy.rake'
  end

end
