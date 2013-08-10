# This doubles as the new client view (if no client ID is provided)
App.controller 'ClientsEditCtrl', ['$scope', '$routeParams', '$timeout', '$location', '$parse', '$rootScope', 'Client', 'ClientChange', 'RecentClients', 'Auth', 'Modal', 'Flash', 'Scroll',\
                                   ($scope, $routeParams, $timeout, $location, $parse, $rootScope, Client, ClientChange, RecentClients, Auth, Modal, Flash, Scroll) ->
  Auth.checkLogin()
  $scope.isBroker = Auth.isBroker()

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
    # clear values of null options
    $('select[readonly] option[value=""]').html('')

  # TODO: error should be modal
  $scope.loading = true
  if $scope.clientChangeId
    $scope.$on('$locationChangeSuccess', loadChange = ->
      if $scope.clientChangeId = $location.search().change
        clientChange = ClientChange.get({id: $scope.clientChangeId, location_id: $scope.locationId},
          (->
            $scope.$emit('stopButtonSpinner')
            $scope.loading = false
            $scope.clientChange = clientChange
            $scope.client = clientChange.client_data
            $scope.changedFields = clientChange.changed_fields
            $scope.changedSections = clientChange.changed_sections
            $scope.prevChangeId = clientChange.prev_change_id
            $scope.nextChangeId = clientChange.next_change_id
            $scope.curChangeNum = clientChange.cur_change_num
            $scope.changeCount = clientChange.change_count
            $scope.client.id = $scope.clientId
            RecentClients.logClientShow($scope.client)),
          (data) ->
            alert('The requested client was not found.')
            $location.url('/clients/index'))
    )
    loadChange()
  else if $scope.clientId
    $scope.client = Client.get(id: $scope.clientId,
      (->
        if $scope.inLocation
          if !$scope.locationId? || $scope.locationId == ''
            (($scope.client.locations ||= {}).value ||= [])
            $scope.client.locations.value.push({id: generateGUID()})
            $scope.locationId = $scope.client.locations.value.length - 1
          if !$scope.client.locations.value? || $scope.locationId < 0 || $scope.locationId >= $scope.client.locations.value.length
            alert('The requested location was not found.')
          Flash.set('client-focusSection', 'locations')
        else if Flash.get('client-focusSection')
          $timeout (->
            Scroll.to Flash.get('client-focusSection'), 50
          ), 0

        console.log (Date.now() - $rootScope.timer) / 1000
        $scope.loading = false
        RecentClients.logClientShow($scope.client)),
      (data) ->
        RecentClients.removeClient($scope.clientId)
        alert('The requested client was not found.')
        $location.url('/clients/index'))
  else
    $scope.loading = false
    $scope.client = new Client()

  # Override auto-saving's default onLocationChange
  $scope.onLocationChange = (event, newUrl) ->
    if newUrl.indexOf('location') >= 0
      if !$scope.clientForm.$valid
        if !$scope.clientForm.$dirty
          alert('Please fill out some basic information before continuing to this section.')
        else
          alert('Please fix errors in this form before continuing.')
        $scope.$emit('stopButtonSpinner')
        event.preventDefault()
        return false
      else if $scope.clientForm.$dirty
        $scope.saveForm(true, -> window.location = newUrl)
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
        $location.url('/clients/index')
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
    title = ''
    if $scope.inLocation
      if $scope.locationId
        locationNumber = $parse('client.locations.value[locationId].locationNumber.value')($scope) || ''
        title = 'Location ' + locationNumber
      else
        title = 'Location'
    else if $scope.clientChangeId || $scope.clientId
      title = $scope.clientCompany() || 'Client'
    else
      title = 'Client'

    title = (if $scope.clientChangeId then 'History' else 'Details') +
            (if title == '' then title else ': ' + title)
]
