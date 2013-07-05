App.controller 'ClientsRecentCtrl', ['$scope', 'RecentClients', 'Auth', ($scope, RecentClients, Auth) ->
  Auth.checkLogin()

  $scope.clients = RecentClients.clients
]
