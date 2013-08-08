App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth', 'Modal',\
                                      ($scope, Brokerage, Auth, Modal) ->
  Auth.checkLogin()

  $scope.loading = true
  $scope.brokerage = Brokerage.get(
    -> $scope.loading = false
  , -> $scope.loading = false
  )

  $scope.createUser = ->
    if $scope.users.password != $scope.users.password_confirm
      alert 'Passwords do not match.'
      return false

    Modal.toggleModal()
    return true
]
