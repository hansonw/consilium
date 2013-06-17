App.factory 'Client', ['$resource', ($resource) ->
    $resource '/api/clients/:id', format: 'json', id: '@id'
]
