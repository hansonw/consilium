App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth', 'Modal', 'User',\
                                      ($scope, Brokerage, Auth, Modal, User) ->
  Auth.checkBroker()
  $scope.readonly = !Auth.isAdmin()

  $scope.title.text = 'Brokerage'
  $scope.loading = true
  $scope.brokerage = Brokerage.get(
    -> $scope.loading = false
  , -> $scope.loading = false
  )

  $scope.createUser = ->
    if $scope.users.password != $scope.users.password_confirm
      alert 'Passwords do not match.'
      return false

    User.save($scope.users)

    Modal.toggleModal()
    return true
]
