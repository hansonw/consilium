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

App.factory 'AuthSessionStatus', [ ->
  _watches: []
  notifySessionExpired: ->
    watch.sessionExpired() for watch in @_watches
  watch: (fn) ->
    @_watches.push fn
]

App.factory 'AuthHttpInterceptor', ['$q', '$window', '$rootScope', 'AuthSessionStatus', ($q, $window, $rootScope, AuthSessionStatus) ->
  (promise) ->
    promise.then((response) ->
      response
    , (response) ->
      AuthSessionStatus.notifySessionExpired() if response.status == 401
      $q.reject(response)
    )
]

App.factory 'Auth', ['$http', 'AuthToken', 'AuthSessionStatus', ($http, AuthToken, AuthSessionStatus) ->
  _isLoggedIn: true
  _watches: []
  isLoggedIn: -> @_isLoggedIn
  # TODO: There must be a better way to do this. Perhaps in the $get() method.
  init: -> AuthSessionStatus.watch(@)
  login: (credentials) ->
    self = @
    $http.post(
      '/api/auth/login',
      credentials
    ).success((data, status, headers, config) ->
      data.email = credentials.email
      AuthToken.set(JSON.stringify(data))

      self._isLoggedIn = true
      self._notifyWatches()
    ).error((data, status, headers, config) ->
    )
  logout: ->
    self = @
    $http.post(
      '/api/auth/logout',
      AuthToken.addAuthTokenToJSONRequest({}),
    ).success((data, status, headers, config) ->
      AuthToken.remove()

      self._isLoggedIn = false
      self._notifyWatches()
    )
  watch: (fn) ->
    @_watches.push fn
  sessionExpired: ->
    if @_isLoggedIn
      @_isLoggedIn = false
      @_notifyWatches()
  _notifyWatches: ->
    watch(@_isLoggedIn) for watch in @_watches
]
