linkNode = ($scope, elem, attrs) ->
  $scope.node = attrs.node || attrs.name
  $scope.shadow = $scope.node if attrs.shadow?
  $scope.root = $scope.node if attrs.root?
  $scope.writeNode = $scope if attrs.writeNode?
  $scope.syncable = !!attrs.syncable if attrs.syncable?
  $scope.isField = true if attrs.field?

App.directive 'node', [->
  restrict: 'E',
  transclude: true,
  replace: true,
  template: '<span ng-controller="AnonymousCtrl" ng-transclude></span>',
  link: linkNode,
]

# Be careful using this. This applies the 'node' attributes to the scope
# most closely above the current one. This can be mistakenly done multiple
# times on the same scope, since a new scope isn't created when this is
# applied.
App.directive 'node', [->
  restrict: 'A',
  link: linkNode,
]
