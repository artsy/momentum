namespace :momentum do

  desc "Initialize a project with librarian-chef, etc."
  task :init => ['librarian:config', 'librarian:init']

end
