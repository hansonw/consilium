App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth', 'Modal',\
                                      ($scope, Brokerage, Auth, Modal) ->
  Auth.checkLogin()

  $scope.loading = true
  $scope.brokerage = Brokerage.get(
    -> $scope.loading = false
  , -> $scope.loading = false
  )
]
