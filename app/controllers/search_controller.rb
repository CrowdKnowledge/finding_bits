class SearchController < ApplicationController
  def index
    respond_to do |format|
      format.html

      format.json {
        h = {
            language: params[:language],
            search_snippet: params[:search_snippet],
            page: params[:page].to_i
        }

        api_response = ApiResponse.find_by h

        if api_response.nil? # First time this request is received. Queue it up.
          ApiResponse.queue h
          result = {"status" => ApiResponse::RESPONSE_QUEUED}

        elsif api_response.queued? # Already queued, not yet available.
          result = {"status" => ApiResponse::RESPONSE_QUEUED}

        elsif api_response.available?
          result = {
              "status" => ApiResponse::RESPONSE_AVAILABLE,
              "result" => api_response.search_result
          }
        end

        render :json => result
      }
    end
  end
end