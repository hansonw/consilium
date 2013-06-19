App.controller 'ClientsCtrl', ['$scope', 'Client', '$timeout', ($scope, Client, $timeout) ->
  $scope._saveTimeout = 10000
  $scope._lastChange = new Date().getTime()
  $scope.saving = false

  # Detect if it's been over _saveTimeout seconds since the last change to the model.
  # If it has been, save the form progress now.
  $scope.$watch 'client', ( ->
    $timeout (->
      time = new Date().getTime()
      if time - $scope._lastChange >= $scope._saveTimeout
        $scope.saving = true
        $timeout (->
          $scope.saving = false
        ), 2000
    ), $scope._saveTimeout
    $scope._lastChange = new Date().getTime()
  ), true
]
