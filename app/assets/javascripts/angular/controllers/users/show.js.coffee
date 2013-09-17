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
  $scope.title.text = if $scope.userId == 'profile' then 'My Account' else 'User Profile'

  $scope.user = User.get({id: $scope.userId}, ->
    $scope.loading = false
    if $scope.userId == 'profile'
      $scope.userId = $scope.user.id
    else
      $scope.title.text = "#{$scope.user.name}"
    $scope.history = ClientChange.query({user_id: $scope.userId, short: true},
      (-> $scope.historyLoading = false),
      (->
        $scope.historyLoading = false
        $scope.historyError = true)
    )
  , -> $scope.loading = false)
]
