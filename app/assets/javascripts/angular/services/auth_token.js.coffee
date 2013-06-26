App.factory 'AuthToken', ['$resource', 'Offline', ($resource, Offline) ->
  Offline.wrap('AuthToken', $resource('/api/auth', {format: 'json', username: '@username', password: '@password'}, {'save': {method: 'PUT'}}))
]
