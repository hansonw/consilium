App.controller 'ClientsCtrl', ['$scope', 'Client', ($scope, Client) ->
  window.clients = Client.query()
  #window.test = new Client({name: 'test'})
  #window.test.$save()
]
