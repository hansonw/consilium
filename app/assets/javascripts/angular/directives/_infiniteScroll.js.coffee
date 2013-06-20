App.directive 'infiniteScroll', ->
  # attr.update should be a callback to an update function.
  ($scope, elem, attr) ->
    domElem = $(elem[0])
    win = $(window)
    doc = $(document)
    scrollMargin = parseInt(attr.scrollMargin) || 10

    win.bind 'scroll', ->
      bottom = domElem.position().top + domElem.height()
      distFromBottom = bottom - win.scrollTop() - win.height()
      if distFromBottom <= scrollMargin && attr.update?
        # apply seems necessary to force the request immediately
        $scope.$apply $scope.$eval(attr.update)