getData = (resource) ->
  data = {}
  for own key, val of resource
    if key[0] != '$' && # angular variable
       key[0] != '_'    # our own internal variable
      if typeof(val) == 'object'
        data[key] = angular.copy(val)
      else
        data[key] = val
  return data

# Checks if a mobile device has a connection (always true on desktop)
online = ->
  connection_type = navigator.network?.connection?.type
  if connection_type?
    return connection_type != Connection?.NONE
  return navigator.onLine

# By default, just try to match all given keys exactly.
defaultMatch = (params, data) ->
  for key, val of params
    if val instanceof RegExp
      if !data[key]?.match?(val)?
        return false
    else if !angular.equals(data[key], val)
      return false
  return true

# Wraps the localstorage class.
class LocalStorage
  constructor: (@key) ->

  get_db: ->
    try
      return angular.fromJson(window.localStorage.getItem(@key))
    catch err
      return {}

  save_db: (db) ->
    window.localStorage.setItem(@key, angular.toJson(db))

  insert: (resource) ->
    data = getData(resource)

    db = @get_db() || {}
    if db[data.id]
      existing = db[data.id]
      # Prioritize local deletions over changes (for now)
      if existing.id == null
        return existing

      need_update = false
      # Check each field individually, and update
      for key, val of existing
        if val.updated_at?
          if !data[key]?.updated_at? || data[key].updated_at < val.updated_at
            data[key] = val
            need_update = true

    db[data.id] = data
    @save_db(db)
    return if need_update then data else null

  delete: (id, permanent = false) ->
    db = @get_db() || {}
    if permanent
      delete db[id]
    else
      # Mark for deletion. Can't actually delete, or we won't be able to sync it
      db[id].id = null
    @save_db(db)

  get: (id) ->
    @get_db()?[id]

  get_all: ->
    @get_db()? && (key for val, key of @get_db())

# Wraps an angular HTTP resource with offline functionality.
App.factory 'Offline', ['$timeout', 'AuthToken', ($timeout, AuthToken) -> {
  online: online,

  # key - index to use for local storage DB
  # resource - base angular HTTP resource
  # match_fn - select function (for query/get)
  wrap: (key, resource, match_fn = defaultMatch) ->
    storage = new LocalStorage(key)
    class OfflineResource
      constructor: (data = {}) ->
        rsrc = new resource(data)
        angular.extend(this, rsrc)
        # Generate a nearly guaranteed unique id.
        @generate_id() if !@id
        @_save = rsrc.$save.bind(this)
        @_delete = rsrc.$delete.bind(this)

      generate_id: ->
        @id = 'local-' + Date.now() + '-' + Math.floor(Math.random() * 1e9)

      getData: ->
        getData(this)

      isNew: ->
        @id.indexOf('local') == 0

      $save: (success, error) ->
        existing = storage.get(@id)
        for key, val of @getData()
          if val.value? && !angular.equals(val.value, existing?[key]?.value)
            @[key].updated_at = Date.now() # Estimate. Will be updated by the server

        if online()
          @_save(AuthToken.addAuthTokenToJSONRequest({}), (data) =>
            # Delete the temporary model from the local DB if it exists.
            if @isNew()
              storage.delete(@id, true)
            angular.extend(this, data)
            storage.insert(data)
            angular.extend(this, storage.get(@id))
            success(data) if success
          , (data) =>
              if data.status == 410 # GONE; deleted from the server
                storage.delete(@id, true)
              else if data.status == 422 # Validation failed for some reason. Don't save
              else # can't reach the server, we'll just leave it as is
                storage.insert(this)
                OfflineResource.defer(=> success(data)) if success
                return
              OfflineResource.defer(=> error(data)) if error
          )
        else
          storage.insert(this)
          success() if success

      $delete: ->
        storage.delete(@id)
        @_delete(AuthToken.addAuthTokenToJSONRequest({}), (data) =>
          storage.delete(@id, true)) if online()

      # Ensures a function is called after the current method returns.
      @defer: (fn) ->
        $timeout(fn, 0)

      @syncWithLocal: (data) ->
        existing = storage.insert(data)
        if existing?
          if existing.id != null
            angular.extend(data, existing)
            data.$save() if online()
            offline = new OfflineResource(existing)
          else
            data.$delete() if online()
            return null
        else
          offline = new OfflineResource(getData(data))
        return offline

      @sync: (success, error) ->
        # Super simple sync function that checks everything. Can easily be made more efficient
        if online()
          resource.query(AuthToken.addAuthTokenToJSONRequest({}), (data) =>
            serverIds = {}
            for item in data
              serverIds[item.id] = true
              @syncWithLocal(item)

            for id, val of storage.get_db()
              if !val.id?
                offline = new OfflineResource(val)
                offline.id = id
                offline.$delete()
                storage.delete(id, true)
              else if val.id.indexOf('local') == 0
                offline = new OfflineResource(val)
                offline.$save()
              else if !serverIds[id]
                storage.delete(id, true) # Server already deleted these.
            success(data) if success
          , error || angular.noop)
        else
          @defer(error) if error

      @get: (params, success, error) ->
        res = new OfflineResource(params)
        queryLocal = (data) =>
          if params.id
            ret = storage.get(params.id)
            if ret?.id?
              angular.extend(res, ret)
              @defer(=> success(res)) if success
            else
              @defer(=> error(data)) if error
          else if match_fn
            for val in storage.get_all()
              if val.id? && match_fn(params, val)
                angular.extend(res, val)
                @defer(=> success(res)) if success
                return

        if online()
          resource.get(AuthToken.addAuthTokenToJSONRequest(params),
            (data) =>
              @syncWithLocal(data)
              queryLocal()
          , (data) =>
              if data.status == 410 # GONE; this means it was deleted
                res.id = null
                storage.delete(params.id, true)
                @defer(=> error(data)) if error
              else # the server is unreachable; use the cache
                queryLocal()
          )
        else
          queryLocal()

        return res

      @query: (params, success, error) ->
        res = []
        queryLocal = (data) =>
          stored = storage.get_all()
          if stored != false
            start = params.start || 0
            limit = params.limit || 1e9
            index = 0
            for val in stored
              if !val.id?
                continue
              if !match_fn || match_fn(params, val)
                if index >= start && index < start + limit
                  res.push(new OfflineResource(val))
                index++
            @defer(=> success(res)) if success
          else
            @defer(=> error(data)) if error

        if online()
          resource.query(params || {},
            (data) =>
              for result in data
                res.push(@syncWithLocal(result))
              success(res) if success
            , queryLocal)
        else
          queryLocal()

        return res
}]
