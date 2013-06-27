App.factory 'AuthToken', ['$resource', ($resource) ->
  get: ->
    localStorage.getItem('authToken')
  set: (authToken) ->
    localStorage.setItem('authToken', authToken)
  remove: ->
    localStorage.removeItem('authToken')
  addAuthTokenToJSONRequest: (obj) ->
    return if not @get()
    authToken = $.parseJSON(@get() || {})
    obj.email = authToken.email
    obj.auth_token = authToken.auth_token
    obj
]
