App.controller 'AuthLoginCtrl', ['$scope', '$http', '$location', '$rootScope', 'Auth', 'AuthResetPassword', 'Flash',\
                                 ($scope, $http, $location, $rootScope, Auth, AuthResetPassword, Flash) ->
  $scope.title.text = 'Login'
  $scope.didResetPassword = Flash.get 'resetPassword'
  ($scope.loginData ||= {}).email = $location.search().email

  # If the user is already logged in, they don't need to login again.
  if Auth.isLoggedIn()
    $location.url('/')

  Auth.tryAutoLogin()

  $scope.login = ->
    Auth.login($scope.loginData)

  $scope.forgotPassword = ->
    email = $scope.loginData.email
    if !email? || email == ''
      alert('Please enter a valid email address.')
    else
      new AuthResetPassword({id: 'users', email: email}).$save((->
        $scope.didSendResetPassword = true
      ), (data) ->
        if data.status == 404
          alert('No user was found with that email.')
        else
          alert('Could not reset password right now. Please try again later.'))
]
