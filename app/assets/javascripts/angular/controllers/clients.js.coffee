App.controller 'ClientsCtrl', ['$scope', 'Client', '$timeout', ($scope, Client, $timeout) ->
  $scope._saveTimeout = 10000
  $scope._lastChange = new Date().getTime()
  $scope.saving = false
  $scope.dirty = false

  # Adding a watch triggers the watch (yo dawg).
  # Thus we gate the whole dirty check on this flag, and flip it the first time the
  # watch actually gets called.
  $scope._watchAdded = false

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
    $timeout (->
      $scope.saving = false
      $scope.dirty = false
    ), 2000
]
