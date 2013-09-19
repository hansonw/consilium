App.directive 'realtimeFilter', ['$parse', ($parse) ->
  restrict: 'A',
  require: 'ngModel',
  link: ($scope, elem, attrs, ngModel) ->
    unless $scope.readonly
      filters =
        name:
          apply: (text) ->
            text.replace /\w\S*/g, (txt) ->
              txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
          unapply: (text) ->
            text
        currency:
          apply: (text) ->
            return '' if !text? || text.length? == 0
            $parse("'#{text}' | currency")($scope)
          unapply: (text) ->
            Number(text.replace(/[^0-9\.]+/g,""))

      skip = false
      prevCommas = 0
      $scope.$watch attrs.ngModel, ->
        val = elem.val()
        filter = filters[attrs.realtimeFilter]
        caretPos = elem.caret().start

        if attrs.realtimeFilter == 'currency'
          commas = filter.apply(val).split(',').length
          caretPos += commas - prevCommas
          prevCommas = commas

        elem.val(filter.apply(val))
        elem.caret({start: caretPos, end: caretPos})

        if skip
          skip = false
          return
        skip = true
        $parse(attrs.ngModel).assign($scope, filter.unapply(val))
]
