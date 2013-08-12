App.directive 'autoSave', ['$location', '$parse', '$timeout', 'Modal', 'Flash', ($location, $parse, $timeout, Modal, Flash) ->
  ($scope, $elem, attr) ->
    form = $scope[$elem.attr('name')]
    model = attr.autoSave
    syncable = attr.syncable?
    success = $parse(attr.saveSuccess)($scope)
    error = $parse(attr.saveError)($scope)

    saveTimeout = 10000
    lastChange = new Date().getTime()

    $scope.saving = false

    # Adding a watch triggers the watch (yo dawg).
    # Thus we gate the whole dirty check on this flag, and flip it the first time the
    # watch actually gets called.
    $scope._watchAdded = false

    # Detect if it's been over _saveTimeout seconds since the last change to the model.
    # If it has been, save the form progress now.
    $scope.$watch model, ( ->
      return $scope._watchAdded = true if not $scope._watchAdded

      if !form.$dirty || !form.$valid || $scope.readonly
        return

      $scope._saveTimer = $timeout (->
        time = new Date().getTime()
        if time - lastChange >= saveTimeout
          $scope.saveForm(false)
      ), saveTimeout
      lastChange = new Date().getTime()
    ), true

    sameRoute = (url1, url2) ->
      if url1.length > url2.length
        return sameRoute(url2, url1)
      url2.indexOf(url1) == 0 && (url1.length == url2.length || url2[url1.length] == '?')

    oldUrl = $location.absUrl()
    $scope.$on('$locationChangeStart', (event, newUrl) ->
      # Only hook route changes. We can't just listen to routeChangeStart because it can't be cancelled
      if sameRoute(oldUrl, newUrl)
        return
      if $scope.onLocationChange && $scope.onLocationChange(event, newUrl) == false
        return
      if form.$dirty
        if !confirm("You have unsaved changes.\nAre you sure you want to leave this page?")
          $scope.$emit('stopButtonSpinning')
          event.preventDefault()
          return
      oldUrl = newUrl)

    $(window).on('beforeunload', unloadHandler = ->
      if form.$dirty then 'You have unsaved changes.' else undefined)

    $scope.$on('$destroy', ->
      $(window).off('beforeunload', unloadHandler)
      if $scope._saveTimer?
        $timeout.cancel($scope._saveTimer)
    )

    $scope.toggleRadio = (objName, value) ->
      if !$scope.readonly
        obj = $parse(objName)
        obj.assign($scope, if obj($scope) == value then '' else value)
        form.$setDirty()

    $scope.toggleCheckbox = (objName) ->
      if !$scope.readonly
        obj = $parse(objName)
        obj.assign($scope, !obj($scope))
        form.$setDirty()

    $scope.errorCount = ->
      ret = 0
      for key, val of form.$error
        ret += val?.length || 0
      plural = if ret == 1 then '' else 's'
      return "#{ret} error#{plural}"

    $scope.errorText = (error) ->
      errors = {
        "minlength": "too short",
        "maxlength": "too long",
        "required": "required",
        "phone": "not a valid phone number",
        "email": "not a valid email",
        "min": "too small",
        "max": "too large",
        "pattern": "in the wrong format",
      }
      error_str = ''
      for key, val of error
        if val != false
          for err in val
            error_str += " - #{err.$name} is #{errors[key]}\n"
      return error_str

    $scope.saveForm = (manual = true, successCallback)->
      return if !form.$dirty || $scope.saving || $scope.readonly

      if !form.$valid
        if manual
          error_str = $scope.errorText(form.$error)
          alert("Please fix the following errors:\n" + error_str)
        return

      $scope.saving = true
      $scope[model].$save(
        (data) ->
          $scope.saving = false
          form.$setPristine()
          successCallback() if successCallback
          success(data) if success
      , (data) ->
          $scope.saving = false
          error(data) if error
      )

    $scope.addToField = (objName, root) ->
      obj = $scope[objName] || {}
      root = model if !root? or root == ''
      parsed = $parse(root + '.' + objName + (syncable && '.value' || ''))
      collection = parsed($scope)
      if !collection?
        collection = parsed.assign($scope, [])

      modalForm = $scope[objName + 'Form']
      if !modalForm.$valid
        alert("Please fix the following errors:\n" + $scope.errorText(modalForm.$error))
        return

      obj.id ||= generateGUID()

      if obj.$index?
        # Remove the index field and add it back
        collection[obj.$index] = obj
        delete obj.$index
        Flash.set 'flashType', 'edit'
      else
        collection.push(obj)
        Flash.set 'flashType', 'create'

      Flash.set 'flashCollection', objName
      Flash.set 'flashId', obj.id

      form.$setDirty()
      Modal.toggleModal(objName)
      $scope.saveForm(false)
      $scope[objName] = {}

    $scope.editInField = (objName, root, index) ->
      root = model if !root? or root == ''
      parsed = $parse(root + '.' + objName + (syncable && '.value' || ''))
      collection = parsed($scope)
      if !collection?
        collection = parsed.assign($scope, [])

      if index < collection.length
        $scope[objName] = angular.copy(collection[index])
        $scope[objName].$index = index
        Modal.toggleModal(objName)

    $scope.deleteFromField = (objName, root, index) ->
      root = model if !root? or root == ''
      parsed = $parse(root + '.' + objName + (syncable && '.value' || ''))
      collection = parsed($scope)
      if !collection?
        collection = parsed.assign($scope, [])

      if index < collection.length
        collection.splice(index, 1)

      form.$setDirty()
]
