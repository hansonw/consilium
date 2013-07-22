prefillWrapper = ($scope, $elem, $attrs, $parse, fn) ->
  model = $attrs.ngModel
  elem = $($elem)

  elem.focus ->
    value = $parse(model)($scope)
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
        calcValue = $parse($attrs.prefillCalc)($scope)
      catch e
        console.log JSON.stringify e

      if $attrs.type == 'currency'
        calcValue = Math.round(calcValue * 100.0) / 100.0

      setFieldValue($scope, $elem, $parse, model, calcValue)
]
