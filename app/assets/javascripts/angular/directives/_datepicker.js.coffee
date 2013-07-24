App.directive 'datepicker', ['$parse', ($parse) ->
  ($scope, $elem, $attr, $ctrl) ->
    presElem = $elem.parent().find('input[type="text"]')

    $elem.data 'date', null

    $elem.datepicker
      dateFormat: 'yy-mm-dd',
      onSelect: (date) ->
        $elem.data 'date', date
        unixTime = $elem.datepicker('getDate').getTime()/1000
        $parse($attr.model).assign $scope, unixTime
        $scope.$digest()
      ,
      showOn: 'button',
      buttonText: '<i class="icon-calendar"></i>',
    .next().insertBefore($elem)

    $scope.$watch $attr.model, ->
      savedDate = $parse($attr.model) $scope
      $elem.datepicker 'setDate', savedDate

    $elem.on 'change input propertychange paste keyup', (e) ->
      $elem.val $elem.data('date')
]
