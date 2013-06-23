App.controller 'ClientsViewCtrl', ['$scope', '$routeParams', '$location', 'Client', ($scope, $routeParams, $location, Client) ->
  $scope.clientId = $routeParams.clientId
  window.client = $scope.client = Client.get({id: $scope.clientId},
    angular.noop, (data, header) ->
      # TODO: should be a modal
      alert('The requested client was not found.')
      $location.path('/clients'))
]