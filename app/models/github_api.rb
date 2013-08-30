# This class defines all the API calls to be made to Github.
class GithubApi
  BASE_URI = "https://api.github.com/search"
  BETA_HEADER = {"Accept" => 'application/vnd.github.preview.text-match+json'}
  REPOSITORIES_URI = "/repositories"
  CODE_URI = "/code"

  include HTTParty
  base_uri BASE_URI

  def logger
    @logger ||= Logger.new(Rails.root.join("log", "github_api.log"))
  end

  # Get list of repos of the given language filtered by stars.
  # eg:
  #   GithubApi.new.top_repos(language: "ruby", stars: ">50")
  def top_repos(h)
    query = {
        q: "language:#{h[:language]} stars:#{h[:stars]}",
        sort: "stars",
        order: "desc",
        per_page: 100,
        page: h[:page]
    }
    self.class.get(REPOSITORIES_URI, {query: query, headers: BETA_HEADER}).parsed_response["items"]
  end

  # Search Github for a code snippet inside the given list of repositories.
  # Result will include text_matches to highlight the actual code snippet
  # (http://developer.github.com/v3/search/#highlighting-issue-search-results)
  # eg:
  #   GithubApi.new.code_search(search_snippet: "shell escape", repos: ["rails/rails"], page: 1)
  def code_search(h)
    search_snippet = h[:search_snippet]

    # The repo search qualifier should look like '@rails/rails @c42/wrest'
    repos = h[:repos].map {|repo| "@#{repo["full_name"]}"}.join(" ")

    query = {
        q: "#{search_snippet} in:file #{repos}",
        page: h[:page]
    }

    logger.info "#{CODE_URI}, #{query.to_json}"
    self.class.get(CODE_URI, {query: query, headers: BETA_HEADER}).parsed_response["items"]
  end
end