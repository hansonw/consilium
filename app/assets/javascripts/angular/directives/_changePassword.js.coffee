# Show an error if the passwords don't match.
App.directive 'changePassword', ->
  ($scope, elem, attrs) ->
    form = $scope.change_passwordForm
    $scope.$watch 'change_password', (data) ->
      if data
        form.password_confirmation.$setValidity('password_match',
          data.password == data.password_confirmation)
    , true
