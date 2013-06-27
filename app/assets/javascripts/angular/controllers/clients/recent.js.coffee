App.controller 'ClientsRecentCtrl', ['$scope', '$location', 'RecentClients', ($scope, $location, RecentClients) ->
  $scope.clients = RecentClients.clients
  $scope.clientClick = (client_id) ->
    $location.path('/clients/show/' + client_id)
]
