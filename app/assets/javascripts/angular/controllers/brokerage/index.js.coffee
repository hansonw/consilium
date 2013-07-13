App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth',\
                                      ($scope, Brokerage, Auth) ->
  Auth.checkLogin()
]