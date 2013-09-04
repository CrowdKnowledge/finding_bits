angular.module('findingBitsApp').directive('syntaxcode', ($timeout) ->
  return {
    restrict: 'EA',
    replace: true,
    transclude: false,
    scope: { language: "@", snippet: "="},
    template: "<pre></pre>",
    link: (scope, $iElement, iAttrs, ctrl) ->
      scope.$on('$destroy', ->
        $iElement.remove()
      )
      $timeout( ->
        $iElement.html(hljs.highlight(scope.language, scope.snippet, true).value)
      , 0)
      null  # http://stackoverflow.com/questions/15313714/how-to-write-memory-leaked-application-with-angular

  }
)
