# This doubles as the new client view (if no client ID is provided)
App.controller 'ClientsEditCtrl', ['$scope', '$routeParams', '$timeout', '$location', '$parse', '$rootScope', 'Client', 'ClientChange', 'RecentClients', 'Auth', 'Modal', 'Flash',\
                                   ($scope, $routeParams, $timeout, $location, $parse, $rootScope, Client, ClientChange, RecentClients, Auth, Modal, Flash) ->
  Auth.checkLogin()

  $scope.clientId = $routeParams.clientId
  $scope.clientChangeId = $location.search().change
  $scope.inLocation = !!$location.path().match /\/location(\/.*)?$/
  $scope.locationId = $routeParams.locationId

  if $scope.readonly = !!$scope.clientChangeId
    $('input, textarea, select').attr('readonly', true)
    $('input, textarea').attr('placeholder', '')
    # readonly isn't enough for checkboxes and selects
    $('input[type=checkbox]').attr('disabled', true)
    $('input[type=radio]').attr('disabled', true)
    $('select').attr('disabled', true)

  # TODO: error should be modal
  $scope.loading = true
  if $scope.clientChangeId
    $scope.clientChange = ClientChange.get(id: $scope.clientChangeId,
      (->
        $scope.loading = false
        $scope.client = $scope.clientChange.client_data
        $scope.changedFields = $scope.clientChange.changed_fields
        $scope.changedSections = $scope.clientChange.changed_sections
        $scope.client.id = $scope.clientId
        RecentClients.logClientShow($scope.client)),
      (data) ->
        alert('The requested client was not found.')
        $location.url('/clients'))
  else if $scope.clientId
    $scope.client = Client.get(id: $scope.clientId,
      (->
        if $scope.inLocation
          if !$scope.locationId? || $scope.locationId == ''
            (($scope.client.locations ||= {}).value ||= [])
            $scope.client.locations.value.push({})
            $scope.locationId = $scope.client.locations.value.length - 1
          if !$scope.client.locations.value? || $scope.locationId < 0 || $scope.locationId >= $scope.client.locations.value.length
            alert('The requested location was not found.')
          Flash.set('client-focusSection', 'locations')
        else if Flash.get('client-focusSection')
          $timeout (->
            $rootScope.scrollTo(Flash.get('client-focusSection'))
          ), 0

        $scope.loading = false
        RecentClients.logClientShow($scope.client)),
      (data) ->
        RecentClients.removeClient($scope.clientId)
        alert('The requested client was not found.')
        $location.url('/clients'))
  else
    $scope.loading = false
    $scope.client = new Client()

  # Override auto-saving's default onLocationChange
  $scope.onLocationChange = (event) ->
    url = $location.url()
    if url.indexOf('location') >= 0
      if !$scope.clientForm.$valid
        if !$scope.clientForm.$dirty
          alert('Please fill out some basic information before continuing to this section.')
        else
          alert('Please fix errors in this form before continuing.')
        event.preventDefault()
        return false
      else if $scope.clientForm.$dirty
        $scope.saveForm(true, -> $location.url(url))
        event.preventDefault()
        return false

  $scope.subsectionVisible = {}
  $scope.savedOnce = false

  $scope.saveSuccess = ->
    $scope.savedOnce = true
    RecentClients.logClientShow($scope.client)

  $scope.saveError = (data) ->
    # TODO: these should be modals or something.
    if data.status == 410 # Deleted on the server
      if confirm('This document was deleted by another user. Continue working on it?')
        $scope.client.generateId()
        $timeout($scope.saveForm, 0) # defer
      else
        $location.url('/clients')
      # TODO: change the id in the address bar? not too important for mobile
    else if data.status == 422
      error_str = ''
      for name, errors of data.data
        for error in errors
          error_str += ' - ' + name + ' ' + error + "\n"
      alert("Please fix the following errors:\n" + error_str)

  $scope.done = ->
    navigateToDoneURL = ->
      if $scope.inLocation
        # We don't want to undo any GET params we've set, like |change|, so we only
        # alter the path, not the fully qualified URL.
        $location.path("/clients/edit/#{$scope.client.id}")
      else
        $location.url("/clients/show/#{$scope.client.id}")

    if $scope.clientId || $scope.clientForm.$dirty
      if $scope.clientForm.$dirty
        if !$scope.clientForm.$valid
          if confirm('Errors are preventing the form from being saved.\nAre you sure you wish to leave? Any changes will be discarded.')
            $scope.clientForm.$setPristine()
            if $scope.clientId || $scope.savedOnce
              navigateToDoneURL()
            else
              window.history.back()
        else
          # Client may or may not exist yet, but we can still try to save.
          $scope.saveForm(true, navigateToDoneURL)
      else
        # Client exists, no changes.
        navigateToDoneURL()
    else
      # Went to create new client, didn't enter anything. Just go back
      window.history.back()

  $scope.clientCompany = ->
    $parse('client.company.value')($scope)

  $scope.title = ->
    if $scope.inLocation
      if $scope.locationId
        locationNumber = $parse('client.locations.value[locationId].locationNumber.value')($scope) || ''
        return 'Location ' + locationNumber
      else
        return 'Location '
    else if $scope.clientChangeId
      return 'History' + (if $scope.clientCompany() then ': ' + $scope.clientCompany() else '')
    else if $scope.clientId
      return 'Details' + (if $scope.clientCompany() then ': ' + $scope.clientCompany() else '')
    else
      return 'Client Details'
]
