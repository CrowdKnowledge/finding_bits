angular.module('findingBitsApp').controller 'SearchController', ['$log', '$scope', '$http', '$timeout', ($log, $scope, $http, $timeout) ->
  GITHUB_API_HEADER = {"Accept": "application/vnd.github.preview.text-match+json"}

  init = ->
    $scope.request_count = 0
    $scope.form = {
      search_snippet: "devil"
      language: 'ruby',
      page: 1
    }

    $scope.languagesList = [ 'ruby', 'python']

  $scope.search = ->
    $scope.is_searching = true
    $scope.search_results = {}
    $scope.make_jsonp_request()

  $scope.make_jsonp_request = ->
    q = "#{$scope.form.search_snippet} in:file @rails/rails"
    serializedQueryString = jQuery.param {q: q, page: 1}
    $http.get("https://api.github.com/search/code?" + serializedQueryString, { headers: GITHUB_API_HEADER })
      .success( (data, status, headers, config) ->
        $scope.search_results = data["items"]
        $scope.is_searching = false
      )

  # Make a search request, retry if the result isn't immediately available.
  $scope.make_request = (maximum_retries, current_retries=0) ->
    $http.get("search.json", {params: $scope.form})
      .success( (data, status, headers, config) ->
        if data["status"] == 'available'
          $scope.search_results = data["result"]["items"]
          $scope.is_searching = false
        else if data["status"] == 'queued'
          if current_retries+1 == maximum_retries
            $scope.search_status = "Sorry, could not run the query. Please try again after sometime."
          else
            $scope.search_status = "Searching.."
            $timeout (->
              $scope.make_request maximum_retries, current_retries+1
            ), (current_retries*current_retries)*1500
      ).error (data, status, headers, config) ->
        $scope.search_status = "Could not contact the server"
  init()
]