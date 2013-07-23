App.directive 'datepicker', [ ->
  ($scope, $elem, $attr, $ctrl) ->
    $elem.datepicker(
      dateFormat: '@',
      onSelect: (date) ->
        #$ctrl.$setViewValue(date)
        console.log date
        $scope.$apply()
    )
]
