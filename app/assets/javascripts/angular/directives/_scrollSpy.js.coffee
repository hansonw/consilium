App.directive 'scrollSpy', ->
  ($scope, elem, attrs) ->
    win = $(window)
    scrollSpyMargin = parseInt(attrs.scrollSpyMargin) || 30

    win.on 'scroll resize', handler = ->
      scrollTop = win.scrollTop()
      console.log scrollTop

    $scope.$on '$destroy', ->
      win.off 'scroll resize', handler
