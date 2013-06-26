App.controller 'ClientsRecentCtrl', ['$scope', '$location', 'RecentClients', ($scope, $location, RecentClients) ->
  $scope.clients = RecentClients.clients
  $scope.clientClick = (client_id) ->
    $location.path('/clients/view/' + client_id)
]