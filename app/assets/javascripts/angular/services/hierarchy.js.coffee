App.factory 'Hierarchy', [->
  modelPath: ($scope) ->
    path = ''
    scope = $scope
    while scope
      if !scope.anon
        scope = scope.$parent
        continue

      path = scope.node + path
      scope = scope.$parent
      path = ('.' + path) if scope?.anon
    path
]
