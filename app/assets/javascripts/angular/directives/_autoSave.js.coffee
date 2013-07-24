App.directive 'autoSave', ['$parse', '$timeout', 'Modal', ($parse, $timeout, Modal) ->
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

    $scope.$on('$routeChangeStart', (event, newLoc, curLoc) ->
      if $scope.onRouteChange && $scope.onRouteChange(event, newLoc, curLoc) == false
        return
      if form.$dirty
        if !confirm("You have unsaved changes.\nAre you sure you want to leave this page?")
          event.preventDefault())

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

    $scope.errorText = (error) ->
      error_str = ''
      for key, val of error
        if val != false
          for err in val
            error_str += " - #{err.$name} is #{errors[key]}\n"
      return error_str

    $scope.getFieldError = (field, parent_form) ->
      fform = $scope[parent_form + 'Form'] || form
      if fform[field] && fform[field].$error && !fform[field].$pristine
        dom_field = $("[name='#{parent_form + 'Form'}'] [name='#{field}']")
        if !dom_field.is(':focus')
          errs = []
          for key, val of fform[field].$error
            errs.push("Field is #{errors[key]}") if val
          return errs.join('<br />')
      return ''

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
      collection = Object.byString($scope, root + '.' + objName + (syncable && '.value' || ''))

      modalForm = $scope[objName + 'Form']
      if !modalForm.$valid
        alert("Please fix the following errors:\n" + $scope.errorText(modalForm.$error))
        return

      # Evaluation, validation code, etc. should go here.
      # collection -- the collection of objects getting pushed to
      # obj -- the object being pushed

      if obj.$index?
        # Remove the index field and add it back
        collection[obj.$index] = obj
        delete obj.$index
      else
        collection.push(obj)

      form.$setDirty()
      Modal.toggleModal(objName)

    $scope.editInField = (objName, root, index) ->
      root = model if !root? or root == ''
      collection = Object.byString($scope, root + '.' + objName + (syncable && '.value' || ''))

      if index < collection.length
        $scope[objName] = angular.copy(collection[index])
        $scope[objName].$index = index
        Modal.toggleModal(objName)

    $scope.deleteFromField = (objName, root, index) ->
      root = model if !root? or root == ''
      collection = Object.byString($scope, root + '.' + objName + (syncable && '.value' || ''))

      if index < collection.length
        collection.splice(index, 1)

      form.$setDirty()
]
