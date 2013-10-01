App.directive 'condAutofocus', ['$timeout', ($timeout) ->
  ($scope, elem, attrs) ->
    $timeout (->
      elem.focus() if Modernizr.mq(attrs.condAutofocus || 'screen and (min-width:0)')
    ), 1
]
