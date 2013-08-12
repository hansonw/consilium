App.directive 'intelligentText', ['$parse', ($parse) ->
  options = []
  ($scope, $elem, $attr) ->
    fields = $attr.ngModel.split "."
    model = $parse($attr.model)
    modalCollection = fields[0]
    values = []

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
      values = getValues(modelValue, fields)
      console.log values

    $elem.on 'keypress', (e) ->
      val = ($elem.val() || '')
      val = val.slice(0, $elem[0].selectionStart) + String.fromCharCode(e.which) + val.slice($elem[0].selectionEnd)
      if $elem[0].selectionStart == val.length - 1
        match = null
        for value in values
          if value.indexOf(val) == 0
            if !match? || match.length > value.length
              match = value
        console.log match
        if match?
          $elem.val(match)
          $elem[0].selectionStart = val.length
          $elem[0].selectionEnd = match.length
          e.preventDefault()

    $("div#modal-" + modalCollection).on 'modal-toggle', updateValues
    $scope.$on '$destroy', ->
      $("div#modal-" + modalCollection).off 'modal-toggle', updateValues
]
