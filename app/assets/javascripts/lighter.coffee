angular.module('findingBitsApp').directive('syntaxcode', ($timeout) ->
  return {
    restrict: 'EA',
    replace: true,
    transclude: false,
    scope: { language: "@", snippet: "="},
    template: "<pre></pre>",
    link: (scope, $iElement, iAttrs) ->
      $timeout( ->
        $iElement.html(hljs.highlight(scope.language, scope.snippet, true).value)
      , 0)

  }
)
