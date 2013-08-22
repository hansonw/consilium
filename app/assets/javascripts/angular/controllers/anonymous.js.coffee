App.controller 'AnonymousCtrl', ['$scope', 'Hierarchy', ($scope, Hierarchy) ->
  $scope.anon = true

  $scope.modelPath = ->
    Hierarchy.modelPath($scope)

  window.scope = $scope
]
