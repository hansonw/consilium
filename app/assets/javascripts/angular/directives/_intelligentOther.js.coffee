App.directive 'intelligentOther', ['$parse', ($parse) ->
  options = []
  ($scope, $elem, $attr) ->
    fields = $attr.dropdownOther.split "."
    model = $parse($attr.model)
    modalCollection = fields[0]

    defaultOptions = []
    $.each $elem.find('option'), ->
      if $(this).val() != 'Other'
        defaultOptions.push($(this).val())

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
      $elem.append($('<option>').val(value).html(value)) for value in values

    $("div#modal-" + modalCollection).on 'modal-toggle', updateValues
    $scope.$on '$destroy', ->
      $("div#modal-" + modalCollection).off 'modal-toggle', updateValues
]
