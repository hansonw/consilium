App.directive 'realtimeFilter', ['$parse', ($parse) ->
  restrict: 'A',
  require: 'ngModel',
  link: ($scope, elem, attrs, ngModel) ->
    isEmpty = (val) ->
      !val? || val == '' || val == '0' || !val || val.length? == 0

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
            return '' if isEmpty(text)
            $parse("'#{text}' | currency")($scope)
          unapply: (text) ->
            Number(text.replace(/[^0-9\.]+/g,""))
        postal_code:
          apply: (text) ->
            return '' if isEmpty(text)
            text = text.toUpperCase()
            if text?.length > 3 && text[3] != ' ' && !!text.match /.*[a-zA-Z]+.*/
              text = text.slice(0, 3) + ' ' + text.slice(3)
            text
          unapply: (text) ->
            text
        number:
          apply: (text) ->
            text.replace /[^0-9\.\-]/g, ''
          unapply: (text) ->
            text
        integer:
          apply: (text) ->
            text.replace /[^0-9]/g, ''
          unapply: (text) ->
            text

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

      everHadValue = false
      $scope.$watch attrs.ngModel, (newVal, oldVal) ->
        # If the value was completely deleted, leave it.
        if !newVal?
          return

        return if isEmpty(newVal) && isEmpty(oldVal) && !everHadValue
        everHadValue = true

        val = newVal
        filter = filters[attrs.realtimeFilter]
        val = filter.apply(filter.unapply(val))
        elem.val(val)
        if attrs.realtimeFilter == 'postal_code'
          diffSpaces = val?.split(' ').length - oldVal?.split(' ').length
          pos =
            switch diffSpaces
              when 1 then 5
              when -1 then 3
              else -1
          elem.caret({start: pos, end: pos}) if pos != -1
        $parse(attrs.ngModel).assign($scope, filter.unapply(val))
]
