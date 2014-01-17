namespace :librarian do

  LIBRARIAN_CONFIG = <<-EOF
---
LIBRARIAN_CHEF_PATH: #{Momentum.config[:cookbooks_install_path]}
LIBRARIAN_CHEF_INSTALL__STRIP_DOT_GIT: '1'
  EOF

  task :config do
    FileUtils.mkdir_p './.librarian/chef'
    File.open('./.librarian/chef/config', 'w+') do |f|
      f.write(LIBRARIAN_CONFIG)
    end
    $stderr.puts "Wrote .librarian/chef/config"
  end

  task :init => :require do
    # librarian-chef and rails declare incompatible json dependencies,
    # so librarian-chef must be installed but can't be in the bundle
    Bundler.with_clean_env do
      system "librarian-chef init"
    end
  end

  task :require do
    raise "librarian-chef must be installed!" if `which librarian-chef`.empty?
  end
end
