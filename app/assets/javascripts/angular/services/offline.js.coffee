getData = (resource) ->
  data = {}
  for own key, val of resource
    if key[0] != '$' # angular variable
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
      # Prioritize local deletions over changes (for now)
      if existing.id == null
        return existing

      need_update = false
      # Check each field individually, and update
      for key, val in data
        if val.updated_at?
          if !existing[key]?.updated_at? || existing[key].updated_at < val.updated_at
            existing[key] = val
      for key, val in existing
        if val.updated_at?
          if !data[key]?.updated_at? || data[key].updated_at < val.updated_at
            data[key] = val
            need_update = true

      if need_update
        return data

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
    @save_db(db)

  get: (id) ->
    @get_db()?[id]

  get_all: ->
    @get_db()? && (key for val, key of @get_db())

# Wraps an angular HTTP resource with offline functionality.
App.factory 'Offline', ['$timeout', ($timeout) -> {
  # Must provide name to use as the local storage key
  wrap: (key, resource) ->
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

      $save: (success, error) ->
        existing = storage.get(@id)
        for key, val of getData(this)
          if val.value? && !angular.equals(val.value, existing?[key]?.value)
            @[key].updated_at = Date.now() # Estimate. Will be updated by the server

        if online()
          @_save((data, header) =>
            # Delete the temporary model from the local DB if it exists.
            if @id.indexOf('local') == 0
              storage.delete(@id, true)
            angular.extend(this, data)
            storage.insert(data)
            angular.extend(this, storage.get(@id))
            success() if success
          , (data, header) =>
              if data.status == 410 # GONE; deleted from the server
                storage.delete(@id, true)
              else if data.status == 422 # Validation failed for some reason. Don't save
              else # can't reach the server, we'll just leave it as is
                storage.insert(this)
                OfflineResource.defer(=> success(data, header)) if success
                return
              OfflineResource.defer(=> error(data, header)) if error
          )
        else
          success() if success
        
      $delete: ->
        storage.delete(@id)
        @_delete((data, header) =>
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

      @syncAllWithLocal: (dataSet, result) ->
        serverIds = {}
        for data in dataSet
          serverIds[data.id] = true
          if offline = @syncWithLocal(data)
            result.push(offline)
        for id, val of storage.get_db()
          if val.id.indexOf('local') == 0
            offline = new OfflineResource(val)
            result.push(offline)
            offline.$save()
          else if !serverIds[id]
            storage.delete(id, true) # Server already deleted these.

      @sync: (success, error) ->
        if online()
          resource.query({}, (data) =>
            @syncAllWithLocal(data, [])
            success() if success
          , error || angular.noop)
        else
          @defer(error) if error

      @get: (params, success, error) ->
        res = new OfflineResource(params)
        queryLocal = (data, header) =>
          # TODO: differentiate between server deletion/error
          ret = storage.get(params.id)
          if ret?
            angular.extend(res, ret)
            @defer(=> success(res, header)) if success
          else
            @defer(=> error(data, header)) if error

        if online()
          resource.get(params,
            (data, header) =>
              @syncWithLocal(data)
              queryLocal()
          , (data, header) =>
              if data.status == 410 # GONE; this means it was deleted
                res.id = null
                storage.delete(params.id, true)
                @defer(=> error(data, header)) if error
              else # the server is unreachable; use the cache
                queryLocal()
          )
        else
          queryLocal()

        return res

      @query: (params, success, error) ->
        res = []
        queryLocal = (data, header) =>
          ret = storage.get_all()
          if ret != false
            for val in ret
              if !params.query? ||
                 val.name?.value?.match?(///#{params.query}///i)? ||
                 val.company?.value?.match?(///#{params.query}///i)? ||
                 val.email?.value?.match?(/#{params.query}/i)?
                res.push(new OfflineResource(val))
            start = params.start || 0
            res = res.slice(start, params.limit && start + params.limit)
            @defer(=> success(res, header)) if success
          else
            @defer(=> error(data, header)) if error

        if online()
          resource.query(params || {},
            (data, header) =>
              for result in data
                res.push(@syncWithLocal(result))
              success(res, header) if success
            , queryLocal)
        else
          queryLocal()

        return res
}]
