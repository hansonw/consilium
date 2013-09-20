App.directive 'realtimeFilter', ['$parse', ($parse) ->
  restrict: 'A',
  require: 'ngModel',
  link: ($scope, elem, attrs, ngModel) ->
    unless $scope.readonly
      filters =
        name:
          apply: (text) ->
            text.replace /\w\S*/g, (txt) ->
              txt.charAt(0).toUpperCase() + txt.substr(1)
          unapply: (text) ->
            text
        currency:
          apply: (text) ->
            return '' if !text? || text == '' || text == '0' || !text || text.length == 0
            $parse("'#{text}' | currency")($scope)
          unapply: (text) ->
            Number(text.replace(/[^0-9\.]+/g,""))

      if attrs.realtimeFilter == 'currency'
        elem.on 'keydown', (e) ->
          char = String.fromCharCode(e.which)
          val = (elem.val() || '')
          if val == ''
            setTimeout (->
              elem.caret({start: 2, end: 2})
            ), 10

          if char >= '0' && char <= '9'
            caret = elem.caret()
            numCommas = elem.val().split(',').length
            setTimeout (->
              afterNumCommas = elem.val().split(',').length
              pos = caret.start + 1 + afterNumCommas - numCommas
              elem.caret({start: pos, end: pos})
            ), 0
          else if e.which == 8
            caret = elem.caret()
            if val.length > caret.start && (val[caret.start - 1] == ',' || val[caret.start - 1] == '.')
              elem.caret({start: caret.start - 1, end: caret.end - 1})
            numCommas = elem.val().split(',').length
            setTimeout (->
              afterNumCommas = elem.val().split(',').length
              pos = caret.start - 1 + afterNumCommas - numCommas
              elem.caret({start: pos, end: pos})
            ), 0

        elem.on 'keypress', (e) ->
          char = String.fromCharCode(e.which)
          val = (elem.val() || '')
          if char == '.'
            val = val.replace(/\./g, '')
            val = val.slice(0, elem.caret().start) + char + val.slice(elem.caret().end)
            val = filters.currency.unapply(val)
            $parse(attrs.ngModel).assign($scope, val)

            elem.val(filters.currency.apply(val))
            e.preventDefault()

            setTimeout (->
              pos = elem.val().indexOf('.') + 1
              elem.caret({start: pos, end: pos})
            ), 0
          else if char == ',' || char == '$'
            elem.caret({start: elem.caret().start + 1, end: elem.caret().end + 1})
            e.preventDefault()

      skip = false
      $scope.$watch attrs.ngModel, ->
        val = elem.val()
        filter = filters[attrs.realtimeFilter]
        elem.val(filter.apply(val))
        if skip
          skip = false
          return
        skip = true
        $parse(attrs.ngModel).assign($scope, filter.unapply(val))
]
