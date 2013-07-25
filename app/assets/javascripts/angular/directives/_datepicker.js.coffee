App.directive 'datepicker', ['$parse', ($parse) ->
  ($scope, $elem, $attr, $ctrl) ->
    presElem = $elem.parent().find('input[type="text"]')
    clearElem = $elem.parent().find('a')

    $elem.data 'date', null

    button = $elem.datepicker
      dateFormat: 'yy-mm-dd',
      onSelect: (date) ->
        $elem.data 'date', date
        unixTime = Math.floor($elem.datepicker('getDate').getTime()/1000)
        $parse($attr.model).assign $scope, unixTime
        $scope.$digest()
        clearElem.css 'opacity', '1.0'
      ,
      showOn: 'button',
      buttonText: '<i class="icon-calendar"></i>',
    .next()

    # XXX: Checking if the scope is readonly sucks, but the directive is not being passed
    # the readonly information for some reason.
    if $scope.readonly then button.css('display', 'none') else button.insertBefore($elem)
    clearElem.css 'display', 'none' if $scope.readonly

    $scope.$watch $attr.model, ->
      savedDate = $parse($attr.model) $scope
      if savedDate?
        $elem.datepicker 'setDate', new Date(savedDate*1000)
        $elem.data 'date', $elem.val()
        clearElem.css 'opacity', '1.0'
      else
        $elem.val ''
        clearElem.css 'opacity', '0.0'

    $elem.on 'change input propertychange paste keyup', (e) ->
      $elem.val $elem.data('date')

    clearElem.click (e) ->
      $elem.datepicker 'setDate', null
      $elem.data 'date', null
      $parse($attr.model).assign $scope, null
      $scope.$digest()
      clearElem.css 'opacity', '0.0'
]
