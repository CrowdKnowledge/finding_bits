require 'spec_helper'

describe "github api request" do
  it "fetches top repositories from Github for the given language" do
    top_repos = nil
    VCR.use_cassette('github_api/top_repos') do
      top_repos = GithubApi.new.top_repos(language: "ruby", stars: ">50", page: 9)
    end
    expect(top_repos).to be_a_kind_of GithubApi::Response

    # There must always be more than 10 repos with >50stars in Ruby.
    expect(top_repos.results["total_count"]).to be > 10
    expect(top_repos.results["items"].length).to be > 10
  end

  it "searches a list of repositories for a code snippet" do
    search_result = nil
    VCR.use_cassette("github_api/search") do
      search_result = GithubApi.new.code_search(search_snippet: "popen3", repos: ["rails/rails"])
    end

    expect(search_result).to be_an Array
    expect(search_result).to be_present
    expect(search_result)
  end

  describe "paginated response" do
    it "knows whether this is the last page in the response" do
      first_page, second_page, last_page = nil
      VCR.use_cassette('github_api/pagination') do
        first_page = GithubApi.new.top_repos(language: "ruby", stars: ">50", page: 1)
        second_page = GithubApi::Response.new(HTTParty.get(first_page.next_page_url, {headers: GithubApi::BETA_HEADER}))
        last_page = GithubApi::Response.new(HTTParty.get(first_page.last_page_url, {headers: GithubApi::BETA_HEADER}))
      end

      expect(first_page.last_page?).to be false
      expect(second_page.last_page?).to be false
      expect(last_page.last_page?).to be true
    end
  end
end