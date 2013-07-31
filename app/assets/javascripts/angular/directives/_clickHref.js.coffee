App.directive 'clickHref', ['$location', '$parse', '$timeout', '$anchorScroll', ($location, $parse, $timeout, $anchorScroll) ->
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
        old = $location.hash()
        $location.hash(attr.clickHref.slice(1))
        $anchorScroll()
        $location.hash(old)

        if margin = parseInt(attr.clickHrefMargin)
          body = $('body')
          body.scrollTop body.scrollTop() - margin
      else
        firstI = elem.find('i').first()
        if firstI.length
          firstI.addClass 'icon-spin icon-spinner'
        else
          elem.html '<i class="icon-spin icon-spinner"></i> ' + elem.html()

        if attr.clickHref.indexOf('(') != -1
          # It's a callback; call the function.
          $parse(attr.clickHref)($scope)
        else
          window.location = attr.clickHref

      e.preventDefault()
]
