# This doubles as the new client view (if no client ID is provided)
App.controller 'ClientsEditCtrl', ['$scope', '$routeParams', '$timeout', '$location', 'Client', 'RecentClients', ($scope, $routeParams, $timeout, $location, Client, RecentClients) ->
  $scope._saveTimeout = 10000
  $scope._lastChange = new Date().getTime()
  $scope.saving = false
  $scope.dirty = false

  $scope.clientId = $routeParams.clientId
  $scope.title = if $scope.clientId then 'Edit Client' else 'Create Client'

  # Adding a watch triggers the watch (yo dawg).
  # Thus we gate the whole dirty check on this flag, and flip it the first time the
  # watch actually gets called.
  $scope._watchAdded = false

  # Sometimes the act of saving changes the model. We don't really want to mark it as dirty in those cases.
  $scope.lastSaved = null

  # TODO: error should be modal
  $scope.loading = false
  if $scope.clientId
    $scope.loading = true
    $scope.client = Client.get(id: $scope.clientId,
      (->
        $scope.loading = false
        $scope.lastSaved = $scope.client.getData()
        RecentClients.logClientShow($scope.client)),
      (data) ->
        alert('The requested client was not found.')
        $location.path('/clients'))
  else
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

  $scope.$on('$destroy', ->
    if $scope._saveTimer?
      $timeout.cancel($scope._saveTimer)
    $("body").removeClass("modal-active")
  )
  # TODO: Extend the modal directive to be possible to hide from Angular code.

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
    , (data) ->
        $scope.saving = false
        # TODO: these should be modals or something.
        if data.status == 410 # Deleted on the server
          if confirm('This document was deleted by another user. Continue working on it?')
            $scope.client.generate_id()
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
    obj = $scope[objName]
    collection = (($scope.client[objName] ||= {}).value ||= [])

    form = $scope['form' + objName]
    if !form.$valid
      alert("Please fix the following errors:\n" + $scope.errorText(form.$error))
      return

    # Evaluation, validation code, etc. should go here.
    # collection -- the collection of objects getting pushed to
    # obj -- the object being pushed

    if obj.$index?
      # It's already tied to the one in the collection; just remove the index field
      delete obj.$index
    else
      collection.push(obj)

    $scope[objName] = {}
    $('#modalAdd' + objName).toggleClass('active')
    $('body').toggleClass('modal-active')

  $scope.editInField = (objName, index) ->
    collection = (($scope.client[objName] ||= {}).value ||= [])
    if index < collection.length
      $scope[objName] = collection[index]
      $scope[objName].$index = index
      $('#modalAdd' + objName).toggleClass('active')
      $('body').toggleClass('modal-active')

  $scope.deleteFromField = (objName, index) ->
    collection = (($scope.client[objName] ||= {}).value ||= [])
    if index < collection.length
      collection.splice(index, 1)

  $scope.closeModal = (objName) ->
    $scope[objName] = {}

  $scope.done = ->
    window.history.back()
]
