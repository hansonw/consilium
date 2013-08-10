App.controller 'HomeCtrl', ['$scope', 'Client', 'ClientChange', 'Auth',\
                            ($scope, Client, ClientChange, Auth) ->
  Auth.checkLogin()

  if Auth.isBroker()
    $scope.isBroker = true
    $scope.historyLoading = true
    $scope.history = ClientChange.query({short: true},
      (->
        $scope.historyLoading = false),
      (->
        $scope.historyLoading = false
        $scope.historyError = true))
  else
    $scope.clientsLoading = true
    $scope.clients = Client.query({short: true},
      (->
        $scope.clientsLoading = false),
      (->
        $scope.clientsLoading = false
        $scope.clientsError = true))    
]
