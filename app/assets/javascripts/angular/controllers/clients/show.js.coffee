App.controller 'ClientsShowCtrl', ['$scope', '$routeParams', '$location', 'Client', 'Document', 'RecentClients', ($scope, $routeParams, $location, Client, Document, RecentClients) ->
  $scope.clientId = $routeParams.clientId
  $scope.loading = true
  $scope.docLoading = true
  $scope.docError = false
  $scope.client = Client.get({id: $scope.clientId},
    (->
      $scope.loading = false
      RecentClients.logClientShow($scope.client)
      $scope.documents = Document.query({client_id: $scope.client.id}
        (-> $scope.docLoading = false),
        (->
          $scope.docLoading = false
          $scope.docError = true)
      )
    ),
    (data, header) ->
      # TODO: should be a modal
      alert('The requested client was not found.')
      $location.path('/clients'))

  $scope.deleteClient = ->
    # TODO: should be modal
    if confirm('Are you sure? This will delete the client for all other users.')
      $scope.client.$delete()
      $location.path('/clients')

  $scope.generating = false
  $scope.generateDocument = ->
    d = new Document($scope.genDocument)
    d.client_id = $scope.clientId
    $scope.generating = true
    d.$save((data, header) ->
      $scope.documents.splice(0, 0, d)
      $scope.generating = false
    , (data, header) ->
      $scope.generating = false
      alert('Error occurred generating document.')
    )

    $scope.genDocument = {}
    $('#modalAddgenDocument').toggleClass('active')
    $('body').toggleClass('modal-active')

  $scope.deleteDocument = (index) ->
    # TODO: should be modal
    if confirm('Are you sure? This will delete the document for all other users.')
      $scope.documents[index].$delete()
      $scope.documents.splice(index, 1)
]
