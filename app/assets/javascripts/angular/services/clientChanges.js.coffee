App.factory 'ClientChanges', ['$resource', ($resource) ->
  $resource('/api/client_changes/:id', {format: 'json', id: '@id'}, {'save': {method: 'PUT'}})
]
