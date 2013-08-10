App.controller 'ClientsRecentCtrl', ['$scope', 'RecentClients', 'Auth',\
                                     ($scope, RecentClients, Auth) ->
  Auth.checkBroker()

  $scope.clientsLoading = true
  $scope.clientsError = false
  $scope.clients = RecentClients.getClients(
    (->
      $scope.clientsLoading = false),
    (->
      $scope.clientsLoading = false
      $scope.clientsError = true))
]
