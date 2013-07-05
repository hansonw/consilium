App.controller 'HomeCtrl', ['$scope', 'ClientChange', ($scope, ClientChange) ->
  $scope.historyLoading = true
  $scope.history = ClientChange.query({short: true},
    (->
      $scope.historyLoading = false),
    (->
      $scope.historyLoading = false
      $scope.historyError = true))
]
