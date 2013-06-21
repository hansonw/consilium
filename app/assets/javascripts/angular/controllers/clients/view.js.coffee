App.controller 'ClientsViewCtrl', ['$scope', '$routeParams', 'Client', ($scope, $routeParams, Client) ->
  $scope.clientId = $routeParams.clientId
  window.client = $scope.client = Client.get({id: $scope.clientId})
]