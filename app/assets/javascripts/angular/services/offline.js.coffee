getData = (resource) ->
  data = {}
  for own key, val of resource
    data[key] = val
  return data

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

  delete: (id) ->
    db = @get_db() || {}
    delete db[id]
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
    @_save = resource.$save
    @_delete = resource.$delete
  $save: ->
    @updated_at = Date.now() # Estimate. Will be updated by the server
    @storage().insert(this)
    @_save()
  $delete: ->
    @storage().delete(@id)
    @_delete()

# Wraps an angular HTTP resource with offline functionality.
App.factory 'Offline', () -> {
  # Must provide name to use as the local storage key
  wrap: (key, resource) -> {
    storage: new LocalStorage(key)

    get: (params, success, error) ->
      res = new OfflineResource(resource.get(params,
        (data, header) =>
          updated = @storage.insert(data)
          if updated?
            angular.extend(res, updated)
            res.$save()
          success(data, header) if success
      , (data, header) =>
          ret = @storage.get(params)
          if ret?
            success(ret)
          else
            error(data, header) if error
      ), @storage)

    query: (success, error) ->
      res = resource.query(
        (data, header) =>
          for val, i in data
            updated = @storage.insert(val)
            if updated?
              angular.extend(res[i], updated)
              res[i].$save()
          for val, i in res
            res[i] = new OfflineResource(val, @storage)
          res[0].$save()
          success(data, header) if success
        , (data, header) =>
          ret = @storage.get_all()
          if ret != false
            for val in ret
              rsrc = {}
              angular.extend(rsrc, resource, val)
              res.push(new OfflineResource(rsrc, @storage))
            console.log(res)
            success(ret) if success
          else
            error(data, header) if error
      )
  }
}
