# This doubles as the new client view (if no client ID is provided)
App.controller 'ClientsEditCtrl', ['$scope', '$routeParams', '$timeout', '$location', 'Client', 'ClientChange', 'RecentClients', 'Auth', 'Modal',\
                                   ($scope, $routeParams, $timeout, $location, Client, ClientChange, RecentClients, Auth, Modal) ->
  Auth.checkLogin()

  $scope._saveTimeout = 10000
  $scope._lastChange = new Date().getTime()
  $scope.saving = false
  $scope.dirty = false

  $scope.clientId = $routeParams.clientId
  $scope.clientChangeId = $routeParams.clientChangeId
  if $scope.clientChangeId
    $scope.title = 'View Client History'
  else if $scope.clientId
    $scope.title = 'Edit Client'
  else
    $scope.title = 'Create Client'

  # Adding a watch triggers the watch (yo dawg).
  # Thus we gate the whole dirty check on this flag, and flip it the first time the
  # watch actually gets called.
  $scope._watchAdded = false

  # Sometimes the act of saving changes the model. We don't really want to mark it as dirty in those cases.
  $scope.lastSaved = null

  # TODO: error should be modal
  $scope.loading = true
  $scope.savedOnce = false
  if $scope.clientChangeId
    $scope.clientChange = ClientChange.get(id: $scope.clientChangeId,
      (->
        $scope.loading = false
        $scope.client = $scope.clientChange.client_data
        $scope.changedFields = $scope.clientChange.changed_fields
        $scope.changedSections = $scope.clientChange.changed_sections
        $('input, textarea, select').attr('readonly', true)
        $('input, textarea').attr('placeholder', '')
        # readonly isn't enough for checkboxes and selects
        $('input[type=checkbox]').attr('disabled', true)
        $('input[type=radio]').attr('disabled', true)
        $('select').attr('disabled', true)
        $scope.client.id = $scope.clientId
        RecentClients.logClientShow($scope.client)),
      (data) ->
        alert('The requested client was not found.')
        $location.path('/clients'))
  else if $scope.clientId
    $scope.client = Client.get(id: $scope.clientId,
      (->
        $scope.loading = false
        $scope.lastSaved = $scope.client.getData()
        RecentClients.logClientShow($scope.client)),
      (data) ->
        RecentClients.removeClient($scope.clientId)
        alert('The requested client was not found.')
        $location.path('/clients'))
  else
    $scope.loading = false
    $scope.client = new Client()
    $scope.lastSaved = $scope.client.getData()

  $scope.subsectionVisible = {}

  # Detect if it's been over _saveTimeout seconds since the last change to the model.
  # If it has been, save the form progress now.
  $scope.$watch 'client', ( ->
    return $scope._watchAdded = true if not $scope._watchAdded

    if $scope.lastSaved == null || angular.equals($scope.client.getData(), $scope.lastSaved)
      return

    $scope.dirty = true
    if !$scope.newClient.$valid
      return

    $scope._saveTimer = $timeout (->
      time = new Date().getTime()
      if time - $scope._lastChange >= $scope._saveTimeout
        $scope.saveForm(false)
    ), $scope._saveTimeout
    $scope._lastChange = new Date().getTime()
  ), true

  $scope.$on('$locationChangeStart', (event) ->
    if $scope.dirty
      if !confirm("You have unsaved changes.\n\nAre you sure you want to leave this page?")
        event.preventDefault())
  $(window).on('beforeunload', unloadHandler = ->
    if $scope.dirty then 'You have unsaved changes.' else null)

  $scope.$on('$destroy', ->
    $(window).off('beforeunload', unloadHandler)
    if $scope._saveTimer?
      $timeout.cancel($scope._saveTimer)
  )

  $scope.openCamera = () ->
    $('#camera').css({
        position:'absolute',
        top: 0,
        left: 0,
        height: '100%',
        width: '100%'
    });

  $scope.closeCamera = () ->
    $('#camera').css({
        position:'absolute',
        top: 0,
        left: 0,
        height: 0,
        width: 0,
    });

  $scope.toggleRadio = (objName, value) ->
    if !$scope.clientChangeId
      # It's assumed that value does not have to be quote-escaped.
      $scope.$eval("#{objName} = (#{objName} == '#{value}' ? '' : '#{value}')")

  $scope.toggleCheckbox = (objName) ->
    if !$scope.clientChangeId
      $scope.$eval("#{objName} = !#{objName}")

  $scope.errorCount = ->
    ret = 0
    for key, val of $scope.newClient.$error
      ret += val?.length || 0
    plural = if ret == 1 then '' else 's'
    return "#{ret} error#{plural}"

  $scope.errorText = (error) ->
    error_str = ''
    for key, val of error
      if val != false
        for err in val
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
          error_str += " - #{err.$name} is #{errors[key]}\n"
    return error_str

  $scope.saveForm = (manual = true)->
    return if !$scope.dirty || $scope.saving

    if !$scope.newClient.$valid
      if manual
        error_str = $scope.errorText($scope.newClient.$error)
        alert("Please fix the following errors:\n" + error_str)
      return

    $scope.saving = true
    $scope.client.$save(
      ->
        $scope.saving = $scope.dirty = false
        RecentClients.logClientShow($scope.client)
        $scope.lastSaved = $scope.client.getData()
        $scope.savedOnce = true
    , (data) ->
        $scope.saving = false
        # TODO: these should be modals or something.
        if data.status == 410 # Deleted on the server
          if confirm('This document was deleted by another user. Continue working on it?')
            $scope.client.generateId()
            $timeout($scope.saveForm, 0) # defer
          else
            $location.path('/clients')
          # TODO: change the id in the address bar? not too important for mobile
        else if data.status == 422
          error_str = ''
          for name, errors of data.data
            for error in errors
              error_str += ' - ' + name + ' ' + error + "\n"
          alert("Please fix the following errors:\n" + error_str)
    )

  $scope.addToField = (objName) ->
    obj = $scope[objName] || {}
    collection = (($scope.client[objName] ||= {}).value ||= [])

    form = $scope['form' + objName]
    if !form.$valid
      alert("Please fix the following errors:\n" + $scope.errorText(form.$error))
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

    Modal.toggleModal(objName)

  $scope.editInField = (objName, index) ->
    collection = (($scope.client[objName] ||= {}).value ||= [])
    if index < collection.length
      $scope[objName] = angular.copy(collection[index])
      $scope[objName].$index = index
      Modal.toggleModal(objName)

  $scope.deleteFromField = (objName, index) ->
    collection = (($scope.client[objName] ||= {}).value ||= [])
    if index < collection.length
      collection.splice(index, 1)

  $scope.done = ->
    if $scope.clientId || $scope.savedOnce
      $location.path("/clients/show/#{$scope.client.id}")
    else
      window.history.back()
]
