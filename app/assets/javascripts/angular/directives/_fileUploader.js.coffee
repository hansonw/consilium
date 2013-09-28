App.directive 'fileUploader', ['$parse', ($parse) ->
  ($scope, elem, attrs) ->
    form = elem.parents('form')
    # HACK: angular doesn't recognize input type=file.
    # Create a fake control for the purposes of form error checking.
    ctrl = {$name: elem.attr('name')}
    model = attrs.model

    elem.on('change', (evt) ->
      ngForm = $scope[$scope.node + 'Form'] # can't be set before the form loads
      if evt.target.files.length == 1
        ngForm.$setValidity('required', true, ctrl)
        ngForm.$setValidity('uploading', false, ctrl)
        if FileReader?
          file = evt.target.files[0]
          reader = new FileReader()
          reader.onloadend = ->
            $parse(model).assign($scope, file.name)
            ngForm.$setValidity('uploading', true, ctrl)
          $scope.$digest()
          reader.readAsDataURL(file)
        else
          alert('File uploads are not supported on your browser.')
      else
        ngForm.$setValidity('required', false, ctrl)
        $parse(model).assign($scope, '')
    )

    elem.parents('.modal').on 'modal-toggle', ->
      form[0].reset()
      ngForm = $scope[$scope.node + 'Form']
      if attrs.required
        ngForm.$setValidity('required', false, ctrl)
]
