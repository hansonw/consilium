App.controller 'AuthLoginCtrl', ['$scope', '$http', '$location', '$rootScope', 'Auth', 'Flash',\
                                 ($scope, $http, $location, $rootScope, Auth, Flash) ->
  $scope.title.text = 'Login'
  $scope.didResetPassword = Flash.get 'resetPassword'
  ($scope.loginData ||= {}).email = $location.search().email

  # If the user is already logged in, they don't need to login again.
  if Auth.isLoggedIn()
    $location.url('/')

  $scope.login = ->
    Auth.login($scope.loginData)
]
