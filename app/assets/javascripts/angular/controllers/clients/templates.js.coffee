App.controller 'ClientsTemplatesCtrl', ['$scope', '$location', '$routeParams', '$timeout', 'Auth', 'Client', 'ClientChange', 'Modal', 'RecentClients', 'DocumentTemplate', \
                                        ($scope, $location, $routeParams, $timeout, Auth, Client, ClientChange, Modal, RecentClients, DocumentTemplate) ->
  Auth.checkBroker()

  $scope.title.text = 'Edit Templates'
  $scope.clientId = $routeParams.clientId
  $scope.clientChangeId = $location.search().change
  $scope.loading = if $scope.clientChangeId then 2 else 1
  $scope.templatesLoading = true
  $scope.downloadMenu = {}

  $scope.client = Client.get({id: $scope.clientId},
    (->
      $scope.loading -= 1
      $scope.title.text = 'Edit Templates for ' + $scope.client.company_name.value
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
    if !template.sections?.length
      alert 'This template cannot be edited.'
      return

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

  $scope.resetSection = (index) ->
    if index?
      section = $scope.template.sections[index]
    else if !confirm 'Are you sure? This will delete all uploaded sections for this template.'
      return

    new DocumentTemplate().$delete({
      client_id: $scope.clientId,
      template: $scope.template.file,
      section: section?.id
    }, ->
      if section
        delete section.updated_at
        delete section.updated_by
      else
        delete $scope.template.updated_at
        for section in $scope.template.sections
          delete section.updated_at
          delete section.updated_by
    , ->
      alert 'Error reverting this section.'
    )

  $scope.uploading = {}
  upload.on('change', (evt) ->
    if evt.target.files.length == 1
      if FileReader?
        file = evt.target.files[0]
        if file.name.match /\.docx$/
          reader = new FileReader()
          reader.onloadend = ->
            section = $scope.section # This could change while uploading.
            new DocumentTemplate({
              client_id: $scope.clientId
              template: $scope.template.file,
              section: section.id,
              data: reader.result,
            }).$save(->
              $scope.uploading[section.id] = false
              section.updated_by = Auth.getEmail()
              $scope.template.updated_at = section.updated_at = Util.unixTimestamp()
            , ->
              $scope.uploading[section.id] = false
              alert 'Could not process the given document.'
            )
          $scope.uploading[$scope.section.id] = true
          $scope.$digest()
          reader.readAsDataURL(file)
          form[0].reset()
        else
          alert 'You must upload a Word document (docx).'
      else
        form.submit()
  )
]
