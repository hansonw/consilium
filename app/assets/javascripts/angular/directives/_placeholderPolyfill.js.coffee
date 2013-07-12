App.directive 'placeholderPolyfill', [ ->
  ($scope, $elem, $attr) ->
    $scope.$watch $attr.ngModel, (newVal, oldVal) ->
      $elem.css 'color', if newVal then 'inherit' else '#aaa'
]
