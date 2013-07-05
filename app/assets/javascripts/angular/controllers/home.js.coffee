App.controller 'HomeCtrl', ['$scope', 'ClientChange', 'Auth', ($scope, ClientChange, Auth) ->
  Auth.checkLogin()

  $scope.historyLoading = true
  $scope.history = ClientChange.query({short: true},
    (->
      $scope.historyLoading = false),
    (->
      $scope.historyLoading = false
      $scope.historyError = true))
]
