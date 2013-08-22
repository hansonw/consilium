App.directive 'node', [->
  restrict: 'E',
  transclude: true,
  replace: true,
  template: '<span ng-controller="AnonymousCtrl"><span ng-transclude></span></span>'
  link: ($scope, elem, attrs) ->
    $scope.node = attrs.name
]
