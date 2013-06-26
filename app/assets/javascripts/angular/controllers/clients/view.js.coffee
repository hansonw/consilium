App.controller 'ClientsViewCtrl', ['$scope', '$routeParams', '$location', 'Client', 'RecentClients', ($scope, $routeParams, $location, Client, RecentClients) ->
  $scope.clientId = $routeParams.clientId
  $scope.client = Client.get({id: $scope.clientId},
    (->
      RecentClients.logClientView($scope.client)),
    (data, header) ->
      # TODO: should be a modal
      alert('The requested client was not found.')
      $location.path('/clients'))

  $scope.deleteClient = ->
    # TODO: should be modal
    if confirm('Are you sure? This will delete the client for all other users.')
      $scope.client.$delete()
      $location.path('/clients')
]