App.controller 'ClientsShowCtrl', ['$scope', '$routeParams', '$location', '$filter', 'Client', 'ClientChange', 'Document', 'RecentClients', 'Auth', ($scope, $routeParams, $location, $filter, Client, ClientChange, Document, RecentClients, Auth) ->
  Auth.checkLogin()

  $scope.clientId = $routeParams.clientId
  $scope.loading = $scope.historyLoading = $scope.documentsLoading = true
  $scope.historyError = $scope.documentsError = false
  $scope.title = 'View Client'
  $scope.client = Client.get({id: $scope.clientId},
    (->
      $scope.loading = false
      RecentClients.logClientShow($scope.client)
      $scope.history = ClientChange.query({client_id: $scope.client.id, short: true},
        (-> $scope.historyLoading = false),
        (->
          $scope.historyLoading = false
          $scope.historyError = true)
      )
      $scope.documents = Document.query({client_id: $scope.client.id},
        (-> $scope.documentsLoading = false),
        (->
          $scope.documentsLoading = false
          $scope.documentsError = true)
      )
    ),
    (data, header) ->
      # TODO: should be a modal
      RecentClients.removeClient($scope.clientId)
      alert('The requested client was not found.')
      $location.path('/clients'))

  $scope.deleteClient = ->
    # TODO: should be modal
    if confirm('Are you sure? This will delete the client for all other users.')
      $scope.client.$delete()
      $location.path('/clients')

  $scope.setClientChange = (change) ->
    doc = ($scope.genDocument ||= {})
    doc.changeDescription =
      change.description + ' by ' + change.user_email + ' at ' + $filter('date')(change.updated_at, 'medium')
    doc.client_change_id = change.id

  $scope.generating = false
  $scope.generateDocument = ->
    d = new Document($scope.genDocument)
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

  $scope.closeModal = (objName) ->
    $scope[objName] = {}
]
