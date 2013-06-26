App.factory 'Client', ['$resource', 'Offline', ($resource, Offline) ->
  Offline.wrap 'Client', $resource('/api/clients/:id', {format: 'json', id: '@id'}, {'save': {method: 'PUT'}}),
    (params, val) ->
      if params.query?
        return val.name?.value?.match?(///#{params.query}///i)? ||
               val.company?.value?.match?(///#{params.query}///i)? ||
               val.email?.value?.match?(/#{params.query}/i)?
      else if params.filter?
        for key, str of params.filter
          if !val[key]?.value?.match?(///#{str}///i)?
            return false
      return true
]
