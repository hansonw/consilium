App.controller 'ClientsRecentCtrl', ['$scope', 'RecentClients', 'Auth',\
                                     ($scope, RecentClients, Auth) ->
  Auth.checkLogin()

  $scope.clientsLoading = true
  $scope.clientsError = false
  $scope.clients = RecentClients.getClients(
    (->
      $scope.clientsLoading = false),
    (->
      $scope.clientsLoading = false
      $scope.clientsError = true))
]
