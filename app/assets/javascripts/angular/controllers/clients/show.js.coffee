App.controller 'ClientsShowCtrl', ['$scope', '$routeParams', '$location', '$filter', 'Client', 'ClientChange', 'Document', 'RecentClients', 'Auth', 'Modal',\
                                   ($scope, $routeParams, $location, $filter, Client, ClientChange, Document, RecentClients, Auth, Modal) ->
  Auth.checkLogin()
  $scope.isBroker = Auth.isBroker()

  $scope.clientId = $routeParams.clientId
  $scope.loading = $scope.historyLoading = $scope.documentsLoading = true
  $scope.historyError = $scope.documentsError = false
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
      RecentClients.removeClient($scope.clientId)
      $location.url('/clients/notfound')
      $location.replace()

  $scope.deleteClient = ->
    # TODO: should be modal
    if confirm('Are you sure? This will delete the client for all other users.')
      $scope.client.$delete()
      $location.url('/clients/index'))

  $scope.setClientChange = (change, index) ->
    doc = ($scope.genDocument ||= {})
    doc.changeDescription =
      change.description + ' by ' + change.user_email + ' at ' + $filter('date')(change.updated_at, 'medium')
    if index == 0
      doc.changeDescription = "Current revision (#{doc.changeDescription})"
    doc.description = change.client_company
    doc.client_change_id = change.id

  $scope.genFromRecent = ->
    if $scope.history.length
      $scope.setClientChange($scope.history[0], 0)
      Modal.toggleModal('genDocument')

  $scope.generating = false
  $scope.generateDocument = ->
    d = new Document($scope.genDocument)
    $scope.generating = true
    d.$save((data, header) ->
      $scope.documents.splice(0, 0, d)
      $scope.generating = false
      window.location = "/api/documents/#{d.id}"
    , (data, header) ->
      $scope.generating = false
      alert('Error occurred generating document.')
    )

    $scope.genDocument = {}
    Modal.toggleModal('genDocument')

  $scope.deleteDocument = (index) ->
    # TODO: should be modal
    if confirm('Are you sure? This will delete the document for all other users.')
      $scope.documents[index].$delete()
      $scope.documents.splice(index, 1)
]
