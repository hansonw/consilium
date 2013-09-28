App.directive 'autoSave', ['$location', '$parse', '$timeout', 'Hierarchy', 'Modal', 'Flash', ($location, $parse, $timeout, Hierarchy, Modal, Flash) ->
  ($scope, $elem, attr) ->
    form = $scope[$elem.attr('name')]
    model = attr.autoSave
    syncable = attr.syncable?
    success = $parse(attr.saveSuccess)($scope)
    error = $parse(attr.saveError)($scope)

    saveTimeout = 10000
    lastChange = Date.now()

    # an "AFK" timer; if there's a delay between edits it probably means the user got distracted
    editTimeout = 20000
    # modals could take a while, so allot 5mins
    modalEditTimeout = 60000 * 5
    lastEdit = Date.now()
    lastModalToggle = Date.now()

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

      time = Date.now()
      if time - lastEdit < editTimeout ||
         lastEdit == lastModalToggle && time - lastEdit < modalEditTimeout
        $scope.editingTime ||= $scope[model].editing_time || 0
        $scope.editingTime += (time - lastEdit) / 1000
      lastEdit = time

      $scope._saveTimer = $timeout (->
        time = new Date().getTime()
        if time - lastChange >= saveTimeout
          $scope.saveForm(false)
      ), saveTimeout
      lastChange = time
    ), true

    # accurately measure how long it takes to edit modals
    $('.modal').on 'modal-toggle', ->
      lastModalToggle = lastEdit = Date.now()

    $scope.$watch 'readonly', (newVal, oldVal) ->
      # readonly isn't enough for checkboxes and selects
      $('input[type=checkbox]').attr('disabled', newVal)
      $('input[type=radio]').attr('disabled', newVal)
      $('select').attr('disabled', newVal)

      if newVal == true
        # clear placeholders
        $('input, textarea').attr('placeholder', '')
        $('select[readonly] option[value=""]').html('')

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
      if !@readonly
        obj = $parse(objName)
        obj.assign(@, if obj(@) == value then '' else value)
        form.$setDirty()

    $scope.toggleCheckbox = (objName) ->
      if !@readonly
        obj = $parse(objName)
        obj.assign(@, !obj(@))
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
        "unique": "not unique",
        "uploading": "still uploading. Please wait for it to finish.",
      }
      error_str = ''
      for key, val of error
        if val != false
          for err in val
            error_str += " - #{Util.humanize(err.$name)} is #{errors[key]}\n"
      return error_str

    $scope.saveForm = (manual = true, successCallback)->
      return if !form.$dirty || $scope.saving || $scope.readonly

      if !form.$valid
        if manual
          error_str = $scope.errorText(form.$error)
          alert("Please fix the following errors:\n" + error_str)
        return

      $scope.saving = true
      $scope[model].editing_time = Math.round($scope.editingTime)

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

    $scope.saveField = (deleteValue = false) ->
      objName = @node
      obj = @writeNode[objName] || {}
      root = @modelPath(true) || model
      parsed = $parse(root)
      collection = parsed($scope)
      collection = parsed.assign($scope, []) if !collection?

      modalForm = @[objName + 'Form']
      if !modalForm.$valid
        alert("Please fix the following errors:\n" + $scope.errorText(modalForm.$error))
        return

      obj.id ||= Util.generateGUID()

      if obj.$index?
        # Remove the index field and add it back
        if deleteValue
          collection.splice(obj.$index, 1)
        else
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
      @writeNode[objName] = {}

    $scope.editInField = (index) ->
      objName = @node
      node = Hierarchy.findWriteNode(objName) || @
      root = node.modelPath(true) || model

      parsed = $parse(root)
      collection = parsed($scope)
      collection = parsed.assign($scope, []) if !collection?

      if index < collection.length
        node[objName] = angular.copy(collection[index])
        node[objName].$index = index
        Modal.toggleModal(objName)

    $scope.deleteFromField = (index) ->
      objName = @node
      node = Hierarchy.findWriteNode(objName) || @
      root = node.modelPath(true) || model
      parsed = $parse(root)
      collection = parsed($scope)
      collection = parsed.assign($scope, []) if !collection?

      if index < collection.length
        collection.splice(index, 1)

      form.$setDirty()
]
