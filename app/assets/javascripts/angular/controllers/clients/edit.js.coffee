# This doubles as the new client view (if no client ID is provided)
App.controller 'ClientsEditCtrl', ['$scope', '$routeParams', 'Client', '$timeout', ($scope, $routeParams, Client, $timeout) ->
  $scope._saveTimeout = 10000
  $scope._lastChange = new Date().getTime()
  $scope.saving = false
  $scope.dirty = false

  $scope.clientId = $routeParams.clientId
  $scope.title = if $scope.clientId then 'Edit Client' else 'Create Client'

  # Adding a watch triggers the watch (yo dawg).
  # Thus we gate the whole dirty check on this flag, and flip it the first time the
  # watch actually gets called.
  $scope._watchAdded = false

  # TODO: show error if this id doesn't exist
  $scope.client = if $scope.clientId then Client.get(id: $scope.clientId) else (new Client())
  window.client = $scope.client
  
  $scope.clientContact = {}

  # Detect if it's been over _saveTimeout seconds since the last change to the model.
  # If it has been, save the form progress now.
  $scope.$watch 'client', ( ->
    return $scope._watchAdded = true if not $scope._watchAdded

    $scope.dirty = true
    $timeout (->
      time = new Date().getTime()
      if time - $scope._lastChange >= $scope._saveTimeout
        $scope.saveForm()
    ), $scope._saveTimeout
    $scope._lastChange = new Date().getTime()
  ), true

  $scope.saveForm = ->
    return if !$scope.dirty || $scope.saving
    $scope.saving = true
    $scope.client.$save(
      (-> $scope.saving = $scope.dirty = false), # success
      (-> $scope.saving = false) # failure (TODO: do something if it keeps failing)
    )

  $scope.addObjectToClient = (objName) ->
    obj = $scope[objName]
    collection = (($scope.client[objName + 's'] ||= {}).value ||= [])

    # Evaluation, validation code, etc. should go here.
    # collection -- the collection of objects getting pushed to
    # obj -- the object being pushed

    collection.push(obj)
    $scope[objName] = {}
]
