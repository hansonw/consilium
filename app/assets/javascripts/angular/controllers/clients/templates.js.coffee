App.controller 'ClientsTemplatesCtrl', ['$scope', '$location', '$routeParams', 'Auth', 'Client', 'Modal', 'RecentClients', 'DocumentTemplate', \
                                        ($scope, $location, $routeParams, Auth, Client, Modal, RecentClients, DocumentTemplate) ->
  Auth.checkBroker()

  $scope.clientId = $routeParams.clientId
  $scope.loading = true

  $scope.client = Client.get({id: $scope.clientId},
    (->
      $scope.loading = false
      RecentClients.logClientShow($scope.client)
      $scope.templatesLoading = true
      $scope.templates = DocumentTemplate.query({client_id: $scope.clientId},
        (-> $scope.templatesLoading = false),
        (-> $scope.templatesLoading = false; $scope.templatesError = true ))
    ),
    (data, header) ->
      RecentClients.removeClient($scope.clientId)
      $location.url('/clients/notfound')
      $location.replace()
  )

  $scope.editTemplate = (template) ->
    # Don't show Save/Cancel, only show Close
    $scope.readonly = true
    template.sections = [
      {id: 'executiveSummary', name: 'Executive Summary'},
      {id: 'servicePlan', name: 'Broker Service Plan'},
      {id: 'claimsManagement', name: 'Claims Management'},
    ]
    $scope.template = template
    Modal.toggleModal('templateEditor')

  form = $('#templateUploader')
  upload = form.find('input[name="upload"]')

  $scope.uploadSection = (section) ->
    upload.click()
    $scope.section = section

  upload.on('change', (evt) ->
    if evt.target.files.length == 1
      if FileReader?
        reader = new FileReader()
        reader.onloadend = ->
          new DocumentTemplate({
            client_id: $scope.clientId
            template: $scope.template.file,
            section: $scope.section.id,
            data: reader.result,
          }).$save(->
            $scope.uploading = null
            $scope.section.updated_by = Auth.getEmail()
            $scope.section.updated_at = Util.unixTimestamp()
          , ->
            $scope.uploading = null
          )
        $scope.uploading = $scope.section.id
        $scope.$digest()
        reader.readAsDataURL(evt.target.files[0])
        form[0].reset()
      else
        form.submit()
  )
]
