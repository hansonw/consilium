App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth',\
                                      ($scope, Brokerage, Auth) ->
  Auth.checkLogin()

  $scope.brokerage = Brokerage.get()

  $scope.submitForm = ->
    if !$scope.saving && $scope.form.$dirty
      $scope.saving = true
      $scope.brokerage.$save((->
        $scope.saving = false
        $scope.form.$setPristine()),
      (-> $scope.saving = false))
]