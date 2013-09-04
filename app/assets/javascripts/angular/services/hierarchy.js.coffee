App.factory 'Hierarchy', ['$rootScope', ($rootScope) ->
  modelPath: ($scope, includeShadow = null) ->
    path = []
    scope = $scope
    while scope
      if !scope.node || (includeShadow == false && scope.shadow == scope.node)
        scope = scope.$parent
        continue

      node = scope.node
      node += '.value' if scope.isField && scope.syncable != false
      path.splice(0, 0, node)
      scope = scope.$parent
    path.join '.'
  ,
  findWriteNode: (name, $scope = null) ->
    $scope ||= $rootScope
    child = $scope.$$childHead
    while child
      if child.node == name && child.writeNode?.node == name
        return child
      found = @findWriteNode(name, child)
      return found if found?
      child = child.$$nextSibling
    null
]
