App.directive 'clickHref', ['$location', '$parse', '$timeout', 'Scroll', ($location, $parse, $timeout, Scroll) ->
  ($scope, $elem, attr) ->
    elem = $elem
    tag = $elem.get(0).tagName.toLowerCase()
    if tag != 'a' && tag != 'button'
      $scope.$evalAsync ->
        elem = $elem.find("button[data-click-href='#{attr.clickHref}']")
        elem = $elem.find("a[data-click-href='#{attr.clickHref}']") if !elem.length
    elem = elem.last()

    $elem.click (e) ->
      if attr.clickHref.slice(0, 1) == '#' && attr.clickHref.indexOf('/') == -1
        margin = 50
        margin = parseInt(attr.clickHrefMargin) if Modernizr.mq(attr.clickHrefCondition || 'screen and (min-width:0)')

        Scroll.to attr.clickHref.slice(1), margin
      else
        firstI = elem.find('i').first()
        if firstI.length
          firstI.addClass 'icon-spin icon-spinner'
        else
          elem.html '<i class="icon-spin icon-spinner"></i> ' + elem.html()
          firstI = elem.find('i').first()

        $scope.$on 'stopButtonSpinner', ->
          firstI.removeClass('icon-spin icon-spinner')

        if attr.clickHref.indexOf('(') != -1
          # It's a callback; call the function.
          $parse(attr.clickHref)($scope)
        else if attr.clickHref[0] == '#'
          $location.url(attr.clickHref.slice(1))
        else
          window.location = attr.clickHref

      e.preventDefault()
]
