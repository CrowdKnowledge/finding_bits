namespace :datastore do
  desc "Retrieve all top repos for Ruby, Python, PHP"
  task :retrieve_top_repos => :environment do

    languages.each { |language|
      puts "Retrieving top #{language} repos.."
      TopRepo.update_top_repos(language, ">50")
    }
  end
end