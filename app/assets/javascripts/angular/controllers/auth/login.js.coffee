App.controller 'AuthLoginCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.loginData =
    email: ''
    password: ''

  $scope.login =
    submit: (form) ->

      $http.post(
        '/api/auth/login',
        $scope.loginData
      ).success((data, status, headers, config) ->
        alert JSON.stringify(data)
      ).error((data, status, headers, config) ->
      )
]
