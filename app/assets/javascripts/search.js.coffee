angular.module('findingBitsApp').controller 'SearchController', ['$log', '$scope', '$http', '$timeout', 'Paginator', ($log, $scope, $http, $timeout, Paginator) ->

  GITHUB_API_HEADER = {
    "Accept": "application/vnd.github.preview.text-match+json",
  }

  init = ->
    $scope.form = {
      search_snippet: "gsub"
      language: 'ruby',
      page: 1
    }

    $scope.languagesList = [ 'ruby', 'python']

  # generates the Github API search URL for the selected language and code snippet.
  codeSearchUrl = ->
    q = "#{$scope.form.search_snippet} in:file @rails/rails"
    serializedQueryString = jQuery.param {q: q, page: $scope.searchPaginator.currentPageNumber}
    "https://api.github.com/search/code?" + serializedQueryString

  # Makes the API request. This is wrapped by Paginator and is invoked by it.
  resultsFetchFn = (current_page_number, paginator_callback) ->
    $scope.is_searching = true
    $scope.search_results = {}
    $http.get(codeSearchUrl(), { headers: GITHUB_API_HEADER })
      .success(paginator_callback)

  # html search()
  $scope.search = ->
    $scope.searchPaginator = Paginator(resultsFetchFn)
    $scope.searchPaginator.search()

  init()
]