App.controller 'AnonymousCtrl', ['$scope', 'Hierarchy', ($scope, Hierarchy) ->
  $scope.modelPath = (includeShadow = null) ->
    Hierarchy.modelPath($scope, includeShadow)

  $scope.findWriteNode = (name) ->
    Hierarchy.findWriteNode($scope, name)
]
