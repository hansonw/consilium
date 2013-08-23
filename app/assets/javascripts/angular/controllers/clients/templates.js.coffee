App.controller 'ClientsTemplatesCtrl', ['$scope', '$location', '$routeParams', '$timeout', 'Auth', 'Client', 'ClientChange', 'Modal', 'RecentClients', 'DocumentTemplate', \
                                        ($scope, $location, $routeParams, $timeout, Auth, Client, ClientChange, Modal, RecentClients, DocumentTemplate) ->
  Auth.checkBroker()

  $scope.clientId = $routeParams.clientId
  $scope.clientChangeId = $location.search().change
  $scope.loading = if $scope.clientChangeId then 2 else 1
  $scope.templatesLoading = true

  $scope.client = Client.get({id: $scope.clientId},
    (->
      $scope.loading -= 1
      RecentClients.logClientShow($scope.client)
      $scope.templates = DocumentTemplate.query({client_id: $scope.clientId},
        (-> $scope.templatesLoading = false),
        (-> $scope.templatesLoading = false; $scope.templatesError = true ))
    ),
    (data, header) ->
      RecentClients.removeClient($scope.clientId)
      $location.url('/clients/notfound')
      $location.replace()
  )

  if $scope.clientChangeId
    $scope.clientChange = ClientChange.get({id: $scope.clientChangeId},
      (->
        $scope.loading -= 1
        if $scope.clientChange.type != 'template'
          $location.url('/clients/notfound')
          $location.replace()),
      (->
        $location.url('/clients/notfound')
        $location.replace())
    )

  $scope.editTemplate = (template) ->
    # Don't show Save/Cancel, only show Close
    $scope.readonly = true
    $scope.template = template
    Modal.toggleModal('templateEditor')

  form = $('#templateUploader')
  upload = form.find('input[name="upload"]')

  $scope.uploadSection = (section) ->
    # Calling it here causes a nested $scope.$apply(). Not really sure why
    $timeout((-> upload.click()), 0)
    $scope.section = section

  upload.on('change', (evt) ->
    if evt.target.files.length == 1
      if FileReader?
        file = evt.target.files[0]
        if file.name.match /\.docx$/
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
              alert 'Could not process the given document.'
            )
          $scope.uploading = $scope.section.id
          $scope.$digest()
          reader.readAsDataURL(file)
          form[0].reset()
        else
          alert 'You must upload a Word document (docx).'
      else
        form.submit()
  )
]
