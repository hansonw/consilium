App.controller 'AnonymousCtrl', ['$scope', 'Hierarchy', ($scope, Hierarchy) ->
  $scope.modelPath = (includeShadow = null) ->
    Hierarchy.modelPath($scope, includeShadow)

  $scope.findWriteNode = (name) ->
    Hierarchy.findWriteNode($scope, name)

  $scope.anonymous = true
  $scope.rootController = ->
    node = $scope.$parent
    while node.anonymous
      node = node.$parent
    return node
]
