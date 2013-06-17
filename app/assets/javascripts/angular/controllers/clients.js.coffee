App.controller 'ClientsCtrl', ['$scope', 'Client', ($scope, Client) ->
  $scope.clients = Client.query()
]
