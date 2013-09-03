class TopRepo < ActiveRecord::Base
  def self.update_top_repos(language, stars)
    repos = GithubApi.new.top_repos(language: language, stars: stars).results["items"].map { |repo|
      h = repo.slice("full_name", "html_url", "forks", "watchers", "language")
      h["language"] = h["language"].downcase
      h
    }

    TopRepo.transaction do
      TopRepo.where(language: language).delete_all
      TopRepo.create! repos
    end
  end
end
