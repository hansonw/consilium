App.controller 'ClientsCtrl', ['$scope', 'Client', '$timeout', ($scope, Client, $timeout) ->
  window.Client = Client
  window.clients = Client.query()
  $scope.saving = false
  $scope.saveTest = ->
    $scope.saving = true
    $timeout (-> $scope.saving = false), 2000
  #window.test = new Client({name: 'test'})
  #window.test.$save()
]
