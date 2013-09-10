class TopRepo
  def self.top_repos(language, stars)
    GithubApi.new.top_repos(language: language, stars: stars).results["items"].map { |repo|
      "@#{repo['full_name']}"
    }.join(" ")
  end

  def self.create_js_asset
    #languages = ["ruby", "python", "php", "javascript", "go", "clojure", "scala", "haskell"]
    languages = ["ruby"]
    top_repos = languages.inject({}) {|h, language| h[language] = TopRepo.top_repos(language, ">50")}
    top_repos = "TOP_REPOS = #{top_repos.to_json}"
    File.open(Rails.root.join("app", "assets", "javascripts", "top_repos.js"), "w") { |f| f.write(top_repos) }
  end
end
