App.factory 'Document', ['$resource', 'Offline', ($resource, Offline) ->
  Offline.wrap 'Document', $resource('/api/documents/:id', {format: 'json', id: '@id'}, {'save': {method: 'PUT'}})
]
