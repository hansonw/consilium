App.directive 'prefill', ->
  ($scope, $elem, $attrs) ->
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
        $scope.$eval("#{model} = '#{$attrs.prefill}'")
