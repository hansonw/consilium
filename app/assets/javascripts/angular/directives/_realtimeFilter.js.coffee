App.directive 'realtimeFilter', ['$parse', ($parse) ->
  restrict: 'A',
  require: 'ngModel',
  link: ($scope, elem, attrs, ngModel) ->
    filters =
      name:
        apply: (text) ->
          text.replace /\w\S*/g, (txt) ->
            txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
        unapply: (text) ->
          text
      currency:
        apply: (text) ->
          #return '' if !text? || text.length? == 0
          #$parse("'#{text}' | currency")($scope)
          text
        unapply: (text) ->
          #Number(text.replace(/[^0-9\.]+/g,""))
          text

    $scope.$watch attrs.ngModel, ->
      val = elem.val()
      filter = filters[attrs.realtimeFilter]
      $parse(attrs.ngModel).assign($scope, filter.unapply(val))
      caretPos = elem.caret().start
      elem.val(filter.apply(val))
      elem.caret({start: caretPos, end: caretPos})
]
