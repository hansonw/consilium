# This doubles as the new client view (if no client ID is provided)
App.controller 'ClientsEditCtrl', ['$scope', '$routeParams', '$timeout', '$location', '$rootScope', 'Client', 'ClientChange', 'RecentClients', 'Auth', 'Modal', 'Flash',\
                                   ($scope, $routeParams, $timeout, $location, $rootScope, Client, ClientChange, RecentClients, Auth, Modal, Flash) ->
  Auth.checkLogin()

  $scope.clientId = $routeParams.clientId
  $scope.clientChangeId = $routeParams.clientChangeId
  $scope.inLocationInfo = !!$location.path().match /\/locationInfo(\/.*)?$/
  $scope.locationInfoId = $routeParams.locationInfoId
  if $scope.inLocationInfo
    if $scope.locationInfoId
      $scope.title = 'Edit Location Info'
    else
      $scope.title = 'Create Location Info'
  else if $scope.clientChangeId
    $scope.title = 'View Client History'
  else if $scope.clientId
    $scope.title = 'Edit Client'
  else
    $scope.title = 'Create Client'

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
        $location.path('/clients'))
  else if $scope.clientId
    $scope.client = Client.get(id: $scope.clientId,
      (->
        if $scope.inLocationInfo
          if !$scope.locationInfoId? || $scope.locationInfoId == ''
            (($scope.client.locationInfos ||= {}).value ||= [])
            $scope.client.locationInfos.value.push({})
            $scope.locationInfoId = $scope.client.locationInfos.value.length - 1
          if !$scope.client.locationInfos.value? || $scope.locationInfoId < 0 || $scope.locationInfoId >= $scope.client.locationInfos.value.length
            alert('The requested location info was not found.')
          Flash.set('client-focusSection', 'locationInfos')
        else if Flash.get('client-focusSection')
          $timeout (->
            $rootScope.scrollTo(Flash.get('client-focusSection'))
          ), 0

        $scope.loading = false
        RecentClients.logClientShow($scope.client)),
      (data) ->
        RecentClients.removeClient($scope.clientId)
        alert('The requested client was not found.')
        $location.path('/clients'))
  else
    $scope.loading = false
    $scope.client = new Client()

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
        $location.path('/clients')
      # TODO: change the id in the address bar? not too important for mobile
    else if data.status == 422
      error_str = ''
      for name, errors of data.data
        for error in errors
          error_str += ' - ' + name + ' ' + error + "\n"
      alert("Please fix the following errors:\n" + error_str)

  $scope.done = ->
    if $scope.inLocationInfo
      window.history.back()
    else if $scope.clientId || $scope.clientForm.$dirty
      if !$scope.clientForm.$valid
        if confirm('Errors are preventing the form from being saved.\nAre you sure you wish to leave? Any changes will be discarded.')
          $scope.clientForm.$setPristine()
          if $scope.clientId || $scope.savedOnce
            $location.path("/clients/show/#{$scope.client.id}")
          else
            window.history.back()
      else if $scope.clientForm.$dirty
        $scope.saveForm(true, ->
          $location.path("/clients/show/#{$scope.client.id}"))
      else
        $location.path("/clients/show/#{$scope.client.id}")
    else
      window.history.back()
]
