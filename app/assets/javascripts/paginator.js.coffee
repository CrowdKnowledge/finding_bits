# GithubAPI results Paginator.
# Wraps the user-supplied `fetchFunction` that makes the actual Github API request.
angular.module("findingBitsApp", []).factory "Paginator", ->
  (fetchFunction) ->
    paginator =

      search: ->
        fetchFunction @currentPageNumber, (data, status, headers ) =>

          this.currentPageItems = data["items"]

          # Github sends pagination information through the Link header.
          pagination_link_header = parse_link_header(headers("link"))
          this.currentPageNumber = @currentPageNumber
          this.prevPageNumber = new Uri(pagination_link_header.prev).getQueryParamValue("page")
          this.lastPageNumber = new Uri(pagination_link_header.last).getQueryParamValue("page")
          this.nextPageNumber = new Uri(pagination_link_header.next).getQueryParamValue("page")

      next: ->
        if @nextPageNumber?
          @currentPageNumber += 1
          @search()

      last: ->
        if @lastPageNumber?
          @currentPageNumber = @lastPageNumber
          @search()

      previous: ->
        if @currentPageNumber isnt 1
          @currentPageNumber -= 1
          @search()

      currentPageItems: []
      currentPageNumber: 1  # Github's page numbering starts from 1

    # Return the paginator function back so that new instances can be created by the user, even though this is a factory.
    paginator
