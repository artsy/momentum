# Helpers for rake tasks

def require_credentials!(args)
  args.with_defaults aws_id: ENV['AWS_ID'], aws_secret: ENV['AWS_SECRET'], to: ENV['RAILS_ENV']
  raise "Must specify target environment (e.g., staging)!" unless args[:to]
  raise "Must set aws_id and aws_secret!" unless args[:aws_id] && args[:aws_secret]
end

def cookbooks_s3_key(to)
  "#{stack_name(to)}.tar.gz"
end

def stack_name(to)
  "#{Momentum.config[:app_base_name]}-#{to}"
end

def system!(command)
  success = system(command)
  fail "Failed with status #{$?.exitstatus}" unless success
end
