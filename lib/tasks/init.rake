namespace :momentum do

  LIBRARIAN_CONFIG = <<-EOF
---
LIBRARIAN_CHEF_PATH: #{Momentum.config[:cookbooks_install_path]}
LIBRARIAN_CHEF_INSTALL__STRIP_DOT_GIT: '1'
  EOF

  desc "Initialize a project with librarian-chef, etc."
  task :init do
    FileUtils.mkdir_p './.librarian/chef'
    File.open('./.librarian/chef/config', 'w+') do |f|
      f.write(LIBRARIAN_CONFIG)
    end
    $stderr.puts "Wrote .librarian/chef/config"
  end
end
