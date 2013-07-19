prefillWrapper = ($scope, $elem, $attrs, fn) ->
  model = $attrs.ngModel
  elem = $($elem)

  elem.focus ->
    # Indirect way of getting the model value, since it's
    # difficult to access directly.
    $scope.__tempPrefillValue = null
    $scope.$eval("__tempPrefillValue = #{model}")
    value = $scope.__tempPrefillValue
    delete $scope.__tempPrefillValue

    if !value? || value == ''
      fn(model, value)

App.directive 'prefill', ->
  ($scope, $elem, $attrs) ->
    prefillWrapper $scope, $elem, $attrs, (model, value) ->
      $scope.$eval("#{model} = '#{$attrs.prefill}'")

App.directive 'prefillCalc', ->
  ($scope, $elem, $attrs) ->
    prefillWrapper $scope, $elem, $attrs, (model, value) ->
      calcValue = null
      console.log $attrs.prefillCalc
      try
        $scope.$eval("__tempPrefillValue = #{$attrs.prefillCalc}")
        calcValue = $scope.__tempPrefillValue
        delete $scope.__tempPrefillValue
      catch e
        console.log JSON.stringify e

      $scope.$eval("#{model} = #{calcValue}")
