App.factory 'Client', ['$resource', ($resource) ->
    $resource '/api/clients/:id', id: '@id'
]
