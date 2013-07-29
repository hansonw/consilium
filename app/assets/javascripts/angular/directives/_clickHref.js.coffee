App.directive 'clickHref', ['$location', '$parse', ($location, $parse) ->
  ($scope, $elem, attr) ->
    elem = $elem
    tag = $elem.get(0).tagName.toLowerCase()
    if tag != 'a' && tag != 'button'
      $scope.$evalAsync ->
        elem = $elem.find("button[data-click-href='#{attr.clickHref}']")
        elem = $elem.find("a[data-click-href='#{attr.clickHref}']") if !elem.length
    elem = elem.last()

    $elem.click (e) ->
      firstI = elem.find('i').first()
      if firstI.length
        firstI.addClass 'icon-spin icon-spinner'
      else
        elem.html '<i class="icon-spin icon-spinner"></i> ' + elem.html()

      # It's a callback; call the function.
      if attr.clickHref.indexOf('(') != -1
        $parse(attr.clickHref)($scope)
      else if attr.clickHref[0] == '#'
        $location.url(attr.clickHref.slice(1))
      else
        window.location = attr.clickHref
      e.preventDefault()
]
