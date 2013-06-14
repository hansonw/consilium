App.controller 'ClientsController', ['$scope', 'Client', ($scope, Client) ->
  $scope.clients = Client.query()
  $scope.test = 'test it works?'
]
