namespace :ow do
  namespace :cookbooks do

    require 'momentum/opsworks'
    require 'momentum/tasks'

    desc "Zip the #{Momentum.config[:cookbooks_install_path]} directory into #{Momentum.config[:cookbooks_install_path]}.zip"
    task :zip do
      raise "No cookbooks found at #{Momentum.config[:cookbooks_install_path]}! Run librarian-chef install." unless File.exists?(Momentum.config[:cookbooks_install_path])
      dir = File.dirname(Momentum.config[:cookbooks_install_path])
      base = File.basename(Momentum.config[:cookbooks_install_path])
      system! "rm -f #{cookbooks_zip} && pushd #{dir} && zip -r #{base} #{base} && popd"
      $stderr.puts "Zipped cookbooks to #{cookbooks_zip}"
    end

    desc "Upload custom cookbooks from #{cookbooks_zip} to S3 (at bucket/appname-env.zip)."
    task :upload, [:to, :aws_id, :aws_secret] => [:require_app_base_name] do |t, args|
      require_credentials!(args)
      require 'aws-sdk'
      AWS.config(access_key_id: args[:aws_id], secret_access_key: args[:aws_secret])

      key = cookbooks_s3_key(args[:to])
      File.open(cookbooks_zip) do |zip|
        AWS::S3.new.client.put_object bucket_name: Momentum.config[:custom_cookbooks_bucket], key: key, data: zip
      end
      $stderr.puts "Uploaded cookbooks.zip to #{Momentum.config[:custom_cookbooks_bucket]}/#{key}."
    end

    desc "Install, zip and upload custom cookbooks, then trigger update_custom_cookbooks command."
    task :update, [:to, :aws_id, :aws_secret] => [:require_app_base_name, 'librarian:install', :zip, :upload] do |t, args|
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
        desc "Zip, upload, and propagate custom OpsWorks cookbooks to the #{env} stack."
        task(env.to_sym) { Rake::Task['ow:cookbooks:update'].invoke(env) }
      end
    end

    task :require_app_base_name do
      raise "An app_base_name must be configured!" unless Momentum.config[:app_base_name]
    end

  end
end
