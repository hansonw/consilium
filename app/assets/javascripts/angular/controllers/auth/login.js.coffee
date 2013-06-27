App.controller 'AuthLoginCtrl', ['$scope', '$http', '$location', '$rootScope', 'AuthToken', ($scope, $http, $location, $rootScope, AuthToken) ->

  # If the user is already logged in, they don't need to login again.
  if $rootScope.isLoggedIn
    $location.path('/')

  $scope.loginData =
    email: ''
    password: ''

  $scope.login =
    submit: (form) ->
      loginEmail = $scope.loginData.email

      $http.post(
        '/api/auth/login',
        $scope.loginData
      ).success((data, status, headers, config) ->
        data.email = loginEmail
        AuthToken.set(JSON.stringify(data))
        $location.path('/')
        $rootScope.isLoggedIn = true
      ).error((data, status, headers, config) ->
      )
]
