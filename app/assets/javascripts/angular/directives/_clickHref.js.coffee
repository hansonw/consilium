App.directive 'clickHref', ['$location', '$parse', '$timeout', ($location, $parse, $timeout) ->
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

      $timeout (->
        if attr.clickHref.indexOf('(') != -1
          # It's a callback; call the function.
          $parse(attr.clickHref)($scope)
        else
          window.location = attr.clickHref
      ), 20

      e.preventDefault()
]
