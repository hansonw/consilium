App.factory 'Document', ['$resource', ($resource) ->
  $resource('/api/documents/:id', {format: 'json', id: '@id'}, {'save': {method: 'PUT'}})
]
