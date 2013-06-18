App.factory 'Client', ['$resource', 'Offline', ($resource, Offline) ->
  Offline.wrap('Client', $resource('/api/clients/:id', format: 'json', id: '@id'))
]
