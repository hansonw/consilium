App.controller 'AuthLoginCtrl', ['$scope', '$http', '$location', '$rootScope', 'Auth',\
                                 ($scope, $http, $location, $rootScope, Auth) ->
  # If the user is already logged in, they don't need to login again.
  if Auth.isLoggedIn()
    $location.path('/')

  $scope.loginData =
    email: ''
    password: ''

  $scope.login =
    submit: (form) ->
      Auth.login($scope.loginData)
]
