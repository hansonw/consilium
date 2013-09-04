App.directive 'intelligent', ['$parse', ($parse) ->
  ($scope, $elem, $attr) ->
    isSelect = $elem.is('select')
    if isSelect
      fields = $attr.dropdownOther.split "."
      defaultOptions = []
      placeholder = ''
      $.each $elem.find('option'), ->
        val = $(this).val()
        if val != 'Other'
          defaultOptions.push val
          if val == ''
            placeholder = $(this).html()
    else
      fields = $attr.ngModel.split "."
      if fields[0] == 'writeNode'
        fields = fields.slice(1)

      values = []
      $elem.on 'keypress', (e) ->
        val = ($elem.val() || '')
        val = val.slice(0, $elem[0].selectionStart) + String.fromCharCode(e.which) + val.slice($elem[0].selectionEnd)
        if $elem[0].selectionStart == val.length - 1
          match = null
          for value in values
            if value.toLowerCase().indexOf(val.toLowerCase()) == 0
              if !match? || match.length > value.length
                match = value
          if match?
            $elem.val(val + match.slice(val.length))
            $elem[0].selectionStart = val.length
            $elem[0].selectionEnd = match.length
            e.preventDefault()

      $elem.on 'blur', ->
        $parse($attr.ngModel).assign($scope, $elem.val())

    model = $parse($attr.model)
    modalCollection = fields[0]

    getValues = (model, fields) ->
      ret = []
      field = fields[0]
      if field == 'value'
        return [model]

      if val = model?[field]?.value
        if val instanceof Array
          for subval in val
            Array::push.apply ret, getValues(subval, fields.slice(1))
        else
          ret = getValues(val, fields.slice(1))
      ret

    updateValues = ->
      oldLocation = $scope.locationId
      locations = $scope.client.locations?.value?.length
      if !locations? || locations == 0
        locations = 1

      $scope.locationId = 0
      values = []
      while $scope.locationId < locations
        modelValue = model($scope)
        values = values.concat(getValues(modelValue, fields))
        $scope.locationId += 1
      $scope.locationId = oldLocation

      if isSelect
        options = angular.copy(defaultOptions)
        values.push('Other')
        for value in values
          if !(value in options)
            options.push(value)
        $elem.empty()
        for value in options
          $elem.append($('<option>').val(value).html(if value == '' then placeholder else value))

    $("div#modal-" + modalCollection).on 'modal-toggle', updateValues
]
