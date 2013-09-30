App.controller 'AuthSignUpCtrl', ['$scope', '$location', 'Auth', 'Flash',\
                                  ($scope, $location, Auth, Flash) ->
  $scope.title.text = 'Sign Up'
  $scope.paid = $location.search().paid

  $scope.signUp = ->
    Auth.signUp($scope.userData, (->
      Auth.login($scope.userData)
    ), (data, status) ->
      if status == 422
        error_str = ''
        for name, errors of data
          for error in errors
            error_str += ' - ' + Util.humanize(name) + ' ' + error + "\n"
        alert("Please fix the following errors:\n" + error_str)
      else
        alert('Could not complete sign up. Please try again later.')
    )

  confirm = $('input[name=password_confirmation')[0]
  $scope.$watch 'userData', (->
    if $scope.userData?.password != $scope.userData?.password_confirmation
      confirm.setCustomValidity('Passwords must match.')
    else
      confirm.setCustomValidity(null)
  ), true
]
