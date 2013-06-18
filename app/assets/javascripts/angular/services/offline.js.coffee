# Wraps the localstorage class.
class LocalStorage
  constructor: (@key) ->
  insert: (_value) ->
    value = {}
    for own key, val of _value
      value[key] = val
    value.id = 1

    console.log(window.localStorage)
    console.log(@key)
    console.log(window.localStorage.getItem(@key))
    stored_value = JSON.parse(window.localStorage.getItem(@key)) || {}    
    if value.id in stored_value
      existing = stored_value[value.id]
      console.log(existing)
      # If our version is newer than the inserted one, an update is in order
      if existing.updated_at > value.updated_at
        return existing
    store[value.id] = value
    window.localStorage.setItem(@key, JSON.stringify(stored_value))
    return null
  get: (params) ->
    window.localStorage.getItem(@key)[params.id]
  get_all: ->
    window.localStorage.getItem(@key)

# Wraps an instance of a HTTP resource with offline functionality.
class OfflineResource
  constructor: (@resource, @storage) ->
    angular.copy(@resource, this)
    @$save = () =>
      @storage.insert()
      @resource.$save()
    @$delete = () =>
      @storage.delete(@resource.id)
      @resource.$delete()

# Wraps an angular HTTP resource with offline functionality.
App.factory 'Offline', () -> {
  # Must provide name to use as the local storage key
  wrap: (key, resource) -> {
    resource: resource,
    storage: new LocalStorage(key),
    # Only supports lookup by ID right now.
    get: (params, success, error) ->
      res = new OfflineResource(resource.get(params,
        (data, header) =>
          updated = @storage.insert(data)
          if updated?
            copy(updated, res)
            @resource.Resource(data).$save()
          success(data, header)
      , (data, header) =>
          ret = @storage.get(params)
          if ret?
            success(ret)
          else
            error(data, header)
      ), @storage)

    query: (success, error) ->
      res = resource.query(
        (data, header) =>
          for val, i in data
            updated = @storage.insert(val)
            if updated?
              console.log(updated)
              copy(updated, res[i])
              @resource.Resource(updated).$save()
          for val, i in res
            res[i] = new OfflineResource(val, @storage)
          success(data, header)
      , (data, header) =>
          ret = @storage.get_all()
          if ret?
            for val in ret
              res.push new OfflineResource(@resource.Resource(val), @storage)
            success(ret)
          else
            error(data, header)
      )
  }
}
