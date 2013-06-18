getData = (resource) ->
  data = {}
  for own key, val of resource
    data[key] = val
  return data

online = () ->
  #return false
  navigator.onLine # temporary, doesn't actually work

# Wraps the localstorage class.
class LocalStorage
  constructor: (@key) ->

  get_db: ->
    JSON.parse(window.localStorage.getItem(@key))

  save_db: (db) ->
    window.localStorage.setItem(@key, JSON.stringify(db))

  insert: (resource) ->
    data = getData(resource)

    db = @get_db() || {}
    if db[data.id]
      existing = db[data.id]
      # If our version is newer than the inserted one, an update is in order
      if existing.updated_at > data.updated_at
        return existing
    db[data.id] = data
    @save_db(db)
    return null

  delete: (id, permanent = false) ->
    db = @get_db() || {}
    if permanent
      delete db[id]
    else
      # Mark for deletion. Can't actually delete, or we won't be able to sync it
      db[id].id = null
      db[id].updated_at = Date.now()
    @save_db(db)

  get: (params) ->
    @get_db()?[params.id]

  get_all: ->
    @get_db()? && (key for val, key of @get_db())

# Wraps an instance of a HTTP resource with offline functionality.
class OfflineResource
  constructor: (resource, storage) ->
    # Hack: use functions so the internal resource won't think they're data
    @resource = () -> resource
    @storage = () -> storage
    angular.extend(this, resource)
    @_save = resource.$save.bind(this)
    @_delete = resource.$delete.bind(this)
  $save: ->
    @updated_at = Date.now() # Estimate. Will be updated by the server
    @storage().insert(this)
    @_save((data, header) =>
      # Delete the temporary model from the local DB if it exists.
      if @id.indexOf('local') == 0
        @storage().delete(@id, true)
      angular.extend(this, data)
      @storage().insert(data)
    ) if online()
  $delete: ->
    @storage().delete(@id)
    @_delete((data, header) =>
      @storage().delete(@id, true)) if online()

# Wraps an angular HTTP resource with offline functionality.
App.factory 'Offline', ['$timeout', ($timeout) -> {
  # Must provide name to use as the local storage key
  wrap: (key, resource) ->
    storage = new LocalStorage(key)

    wrapper = (data) ->
      new_data = {}
      angular.extend(new_data, data)
      if !new_data.id
        # Generate an almost certainly unique ID
        new_data.id = 'local-' + Date.now() + '-' + Math.floor(Math.random()*1e9)
      angular.copy(new OfflineResource(new resource(new_data), wrapper.storage), this)
      return this

    wrapper.storage = storage

    wrapper.defer = (fn) ->
      $timeout(fn, 0)

    wrapper.syncWithLocal = (data) ->
      existing = @storage.insert(data)
      if existing?
        if existing.id != null
          angular.extend(data, existing)
          data.$save() if online()
          offline = new OfflineResource(new resource(existing), @storage)
        else
          data.$delete() if online()
          return null
      else
        offline = new OfflineResource(data, @storage)
      return offline

    wrapper.syncAllWithLocal = (dataSet, result) ->
      serverIds = {}
      for data in dataSet
        serverIds[data.id] = true
        if offline = @syncWithLocal(data)
          result.push(offline)
      for id, val of @storage.get_db()
        if val.id.indexOf('local') == 0
          offline = new OfflineResource(new resource(val), @storage)
          result.push(offline)
          offline.$save()
        else if !serverIds[id]
          @storage.delete(id, true) # Server already deleted these.

    wrapper.get = (params, success, error) ->
      res = new OfflineResource(new resource(), @storage)
      queryLocal = (data, header) =>
        # TODO: differentiate between server deletion/error
        ret = @storage.get(params)
        if ret?
          angular.copy(res, ret)
          @defer(=> success(res, header)) if success
        else
          @defer(=> error(data, header)) if error

      if online()
        resource.get(params,
          (data, header) =>
            @syncWithLocal(data)
            queryLocal()
          , queryLocal)
      else
        queryLocal()

      return res

    wrapper.query = (success, error) ->
      res = []
      queryLocal = (data, header) =>
        ret = @storage.get_all()
        if ret != false
          for val in ret
            res.push(new OfflineResource(new resource(val), @storage))
          @defer(=> success(res, header)) if success
        else
          @defer(=> error(data, header)) if error

      if online()
        resource.query(
          (data, header) =>
            @syncAllWithLocal(data, res)
            success(res, header) if success
          , queryLocal)
      else
        queryLocal()

      return res

    return wrapper
}]
