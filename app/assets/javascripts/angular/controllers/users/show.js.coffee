App.controller 'UsersShowCtrl', ['$scope', '$location', '$routeParams', 'Auth', 'ClientChange', 'User',\
                                 ($scope, $location, $routeParams, Auth, ClientChange, User) ->
  Auth.checkLogin()

  $scope.permissionNames = {}
  $scope.permissionNames[Auth.CLIENT] = 'Client'
  $scope.permissionNames[Auth.BROKER] = 'Broker'
  $scope.permissionNames[Auth.ADMIN]  = 'Admin'

  $scope.loading = true
  $scope.historyLoading = true
  $scope.userId = $routeParams.userId

  $scope.user = User.get({id: $scope.userId}, ->
    $scope.loading = false
    $scope.userId = $scope.user.id # If we're retrieving /users/show/profile
    $scope.history = ClientChange.query({user_id: $scope.userId, short: true},
      (-> $scope.historyLoading = false),
      (->
        $scope.historyLoading = false
        $scope.historyError = true)
    )
  , -> $scope.loading = false)
]
