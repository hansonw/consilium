App.controller 'ClientsRecentCtrl', ['$scope', '$location', 'RecentClients', 'Auth', ($scope, $location, RecentClients, Auth) ->
  Auth.checkLogin()

  $scope.clients = RecentClients.clients
  $scope.clientClick = (client_id) ->
    $location.path('/clients/show/' + client_id)
]
