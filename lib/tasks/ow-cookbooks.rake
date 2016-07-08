namespace :ow do
  namespace :cookbooks do

    require 'momentum/opsworks'
    require 'momentum/tasks'

    desc "Upload custom cookbooks from #{Momentum.config[:cookbooks_install_path]} to S3 (at bucket/appname-env.tar.gz)."
    task :upload, [:to, :aws_id, :aws_secret] => [:require_app_base_name] do |t, args|
      require_credentials!(args)
      require 'aws-sdk'
      AWS.config(access_key_id: args[:aws_id], secret_access_key: args[:aws_secret])

      key = cookbooks_s3_key(args[:to])
      File.open(Momentum.config[:cookbooks_install_path]) do |archive|
        AWS::S3.new.client.put_object bucket_name: Momentum.config[:custom_cookbooks_bucket], key: key, data: archive
      end
      $stderr.puts "Uploaded #{Momentum.config[:cookbooks_install_path]} to #{Momentum.config[:custom_cookbooks_bucket]}/#{key}."
    end

    desc "Package and upload custom cookbooks, then trigger update_custom_cookbooks command."
    task :update, [:to, :aws_id, :aws_secret] => [:require_app_base_name, :berks_package, :upload] do |t, args|
      require_credentials!(args)

      ow = Momentum::OpsWorks.client(args[:aws_id], args[:aws_secret])
      stack = Momentum::OpsWorks.get_stack(ow, stack_name(args[:to]))
      instance_ids = Momentum::OpsWorks.get_online_instance_ids(ow, stack_id: stack[:stack_id])
      if instance_ids.any?
        ow.create_deployment(
          stack_id: stack[:stack_id],
          command: {name: 'update_custom_cookbooks'},
          instance_ids: instance_ids
        )
        $stderr.puts "Triggered 'update_custom_cookbooks' command for #{stack[:name]}... (it might take a few moments)."
      else
        $stderr.puts "No online instances found."
      end
    end

    namespace :update do
      %w{staging production}.each do |env|
        desc "Package, upload, and propagate custom OpsWorks cookbooks to the #{env} stack."
        task(env.to_sym) { Rake::Task['ow:cookbooks:update'].invoke(env) }
      end
    end

    task :require_app_base_name do
      raise "An app_base_name must be configured!" unless Momentum.config[:app_base_name]
    end

    task :berks_package do
      require 'fileutils'
      dirname = File.dirname(Momentum.config[:cookbooks_install_path])
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      system! "berks package #{Momentum.config[:cookbooks_install_path]}"
    end

  end
end
