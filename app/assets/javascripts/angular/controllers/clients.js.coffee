App.controller 'ClientsCtrl', ['$scope', 'Client', ($scope, Client) ->
  $scope.clients = Client.query()
  test = new Client({name: 'test'})
  test.$save()
]
