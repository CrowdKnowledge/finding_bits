class ApiResponse < ActiveRecord::Base
  RESPONSE_AVAILABLE = "available"
  RESPONSE_QUEUED = "queued"

  # Queue up a new ApiResponse request
  def self.queue(h)
    api_response = ApiResponse.create! language: h[:language],
                                       search_snippet: h[:search_snippet],
                                       page: h[:page],
                                       status: ApiResponse::RESPONSE_QUEUED

    Delayed::Job.enqueue GithubCodeSearchJob.new(api_response.id)
  end

  # Has the response been fulfilled and available for consumption?
  def available?
    status == RESPONSE_AVAILABLE
  end

  # Has the request been queued, but not fulfilled?
  def queued?
    status == RESPONSE_QUEUED
  end

  def search_result
    @search_result ||= JSON.parse(response_json)
  end

  # Run the search and save the results
  def search!
    raise "Cannot search on an unqueued request" unless queued?

    @search_result = GithubApi.new.code_search(search_snippet: search_snippet, repos: repos)
    update_attributes(response_json: @search_result.results.to_json, status: ApiResponse::RESPONSE_AVAILABLE)
  end

  # This request has failed permanently. Remove itself so that it will be retried when someone tries again.
  def fail!
    destroy
  end

  # List of top repos for the given language
  def repos
    @repos ||= TopRepo.where(language: language).pluck(:full_name)
  end

end