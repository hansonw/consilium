getData = (resource) ->
  data = {}
  for own key, val of resource
    data[key] = val
  return data

online = () ->
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

  delete: (id) ->
    db = @get_db() || {}
    # Mark for deletion. Can't actually delete, or we won't be able to sync it
    db[data.id].id = null
    db[data.id].updated_at = Date.now()
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
    @_save() if online()
  $delete: ->
    @storage().delete(@id)
    @_delete() if online()

# Wraps an angular HTTP resource with offline functionality.
App.factory 'Offline', () -> {
  counter: 0
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

    # TODO: sync deletes
    wrapper.get = (params, success, error) ->
      res = new OfflineResource(resource.get(params,
        (data, header) =>
          updated = @storage.insert(data)
          if updated?
            angular.extend(res, updated)
            res.$save() if online()
          success(data, header) if success
      , (data, header) =>
          ret = @storage.get(params)
          if ret?
            success(ret)
          else
            error(data, header) if error
      ), @storage)

    # TODO: sync everything
    wrapper.query = (success, error) ->
      res = resource.query(
        (data, header) =>
          for val, i in data
            updated = @storage.insert(val)
            if updated?
              angular.extend(res[i], updated)
              res[i].$save() if online()
          for val, i in res
            res[i] = new OfflineResource(val, @storage)
          res[0].$save()
          success(data, header) if success
        , (data, header) =>
          ret = @storage.get_all()
          if ret != false
            for val in ret
              res.push(new OfflineResource(new resource(val), @storage))
            success(ret) if success
          else
            error(data, header) if error
      )

    return wrapper
}
