prefillCheckIfElemValid = ($scope, $elem) ->
  return $scope.readonly || $elem.is ':disabled'

prefillWrapper = ($scope, $elem, $attrs, $parse, fn) ->
  return if prefillCheckIfElemValid($scope, $elem)

  model = $attrs.ngModel
  elem = $($elem)

  elem.focus ->
    value = $parse(model)($scope)
    if !elem.val()? || elem.val() == ''
      if !value? || value == ''
        fn(model, value)

setFieldValue = ($scope, $elem, $parse, model, value) ->
  $parse(model).assign($scope, value)
  $scope.$digest()
  setTimeout (->
    $($elem).select()
  ), 0

App.directive 'prefill', ['$parse', ($parse) ->
  ($scope, $elem, $attrs) ->
    prefillWrapper $scope, $elem, $attrs, $parse, (model, value) ->
      setFieldValue($scope, $elem, $parse, model, $attrs.prefill)
]

App.directive 'prefillCalc', ['$parse', ($parse) ->
  ($scope, $elem, $attrs) ->
    prefillWrapper $scope, $elem, $attrs, $parse, (model, value) ->
      calcValue = null
      try
        calcValue = $parse($attrs.prefillExpr)($scope)
      catch e
        console.log JSON.stringify e

      if $attrs.type == 'currency'
        calcValue = Math.round(calcValue * 100.0) / 100.0

      setFieldValue($scope, $elem, $parse, model, calcValue)
]

App.directive 'prefillWatch', ['$parse', ($parse) ->
  ($scope, $elem, $attrs) ->
    return if prefillCheckIfElemValid($scope, $elem)

    model = $attrs.ngModel || $attrs.model
    watch = $attrs.prefillWatch
    expr = $attrs.prefillExpr

    attached = false
    watchBlurred = ->
      try
        curVal = $parse(model)($scope)
        watchVal = $parse(watch)($scope)
        $parse(model).assign($scope, $parse(expr)($scope)) if (!curVal? || curVal == '') && watchVal?
        $('[ng-model="' + watch + '"]').off('blur', watchBlurred)
        attached = false
      catch e
        console.log JSON.stringify e

    $scope.$watch watch, ->
      if $attrs.type == 'datepicker'
        watchBlurred()
      else if !attached
        attached = true
        $('[ng-model="' + watch + '"]').on('blur', watchBlurred)

    $scope.$on '$destroy', ->
      $('[ng-model="' + watch + '"]').off('blur', watchBlurred)
]

App.directive 'prefillSequence', ['$parse', ($parse) ->
  ($scope, $elem, attrs) ->
    return if prefillCheckIfElemValid($scope, $elem)

    parentModel = $parse(attrs.prefillSequence)
    model = attrs.ngModel
    parsed = $parse(model)
    fields = model.split('.')
    if fields[0] == 'writeNode'
      fields = fields.slice(1)
    container = fields[0]

    $("div#modal-" + container).on 'modal-toggle', ->
      value = parsed($scope)
      if !value? || value == ''
        c = parentModel($scope)?[container]?.value
        if c? && c.length > 0
          prevValue = $parse(fields.slice(1).join('.'))(c[c.length-1])
        else
          prevValue = '0'
        if prevValue?
          parsed.assign($scope, Util.increment(prevValue))
]
