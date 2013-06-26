App.controller 'AuthLoginCtrl', ['$scope', '$http', 'AuthToken', ($scope, $http, AuthToken) ->
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
      ).error((data, status, headers, config) ->
      )
]
