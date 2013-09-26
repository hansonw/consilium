App.controller 'UsersShowCtrl', ['$scope', '$location', '$routeParams', 'Auth', 'ClientChange', 'Modal', 'User',\
                                 ($scope, $location, $routeParams, Auth, ClientChange, Modal, User) ->
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
    if $scope.user.id == Auth.getUserId()
      $scope.title.text = 'My Account'
      $scope.myAccount = true
    $scope.history = ClientChange.query({user_id: $scope.userId, short: true},
      (-> $scope.historyLoading = false),
      (->
        $scope.historyLoading = false
        $scope.historyError = true)
    )
  , -> $scope.loading = false)

  $scope.changePassword = ->
    data = @change_password
    form = @change_passwordForm
    if data.current_password && data.password && data.password_confirmation &&
       data.password == data.password_confirmation
      $scope.user.current_password = data.current_password
      $scope.user.password = data.password
      $scope.user.password_confirmation = data.password_confirmation
      $scope.user.$update (->
        angular.copy({}, data)
        Modal.toggleModal()
      ), (data) ->
        if data.status == 422
          errorList = []
          for key, errors of data.data
            for error in errors
              errorList.push("#{Util.humanize(key)} #{error}.")
          alert(errorList.join("\n"))
        else
          alert 'Could not change your password at the moment. Please try again later.'
          Modal.toggleModal()
]
