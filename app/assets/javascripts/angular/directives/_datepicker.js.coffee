App.directive 'datepicker', ['$parse', ($parse) ->
  ($scope, $elem, $attr, $ctrl) ->
    presElem = $elem.parent().find('input[type="text"]')

    $elem.data 'date', null

    $elem.datepicker
      dateFormat: 'yy-mm-dd',
      onSelect: (date) ->
        $elem.data 'date', date
        unixTime = Math.floor($elem.datepicker('getDate').getTime()/1000)
        $parse($attr.model).assign $scope, unixTime
        $scope.$digest()
      ,
      showOn: 'button',
      buttonText: '<i class="icon-calendar"></i>',
    .next().insertBefore($elem)

    $scope.$watch $attr.model, ->
      savedDate = $parse($attr.model) $scope
      if savedDate?
        $elem.datepicker 'setDate', new Date(savedDate*1000)
      else
        $elem.val ''

    $elem.on 'change input propertychange paste keyup', (e) ->
      $elem.val $elem.data('date')
]
