App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth', 'Modal',\
                                      ($scope, Brokerage, Auth, Modal) ->
  Auth.checkLogin()

  $scope.brokerage = Brokerage.get()
]
