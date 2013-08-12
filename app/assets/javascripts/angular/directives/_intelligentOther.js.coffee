App.directive 'intelligentOther', ['$parse', ($parse) ->
  options = []
  ($scope, $elem, $attr) ->
    fields = $attr.dropdownOther.split "."
    model = $parse($attr.model)
    modalCollection = fields[0]

    defaultOptions = []
    placeholder = ''
    $.each $elem.find('option'), ->
      val = $(this).val()
      if val != 'Other'
        defaultOptions.push val
        if val == ''
          placeholder = $(this).html()

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
      modelValue = model($scope)
      values = angular.copy(defaultOptions)
      newVals = getValues(modelValue, fields)
      newVals.push('Other')
      for value in newVals
        if !(value in values)
          values.push(value)

      $elem.empty()
      for value in values
        $elem.append($('<option>').val(value).html(if value == '' then placeholder else value))

    $("div#modal-" + modalCollection).on 'modal-toggle', updateValues
    $scope.$on '$destroy', ->
      $("div#modal-" + modalCollection).off 'modal-toggle', updateValues
]
