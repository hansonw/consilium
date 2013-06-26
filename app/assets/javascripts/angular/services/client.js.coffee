App.factory 'Client', ['$resource', 'Offline', ($resource, Offline) ->
  Offline.wrap 'Client', $resource('/api/clients/:id', {format: 'json', id: '@id'}, {'save': {method: 'PUT'}}),
    (params, val) ->
      if params.query?
        if !val.name?.value?.match?(///#{params.query}///i)? &&
           !val.company?.value?.match?(///#{params.query}///i)? &&
           !val.email?.value?.match?(///#{params.query}///i)?
          return false
      if params.filter?
        for key, str of params.filter
          if str != '' && !val[key]?.value?.match?(///#{str}///i)?
            return false
      return true
]
