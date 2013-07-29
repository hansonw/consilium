App.directive 'clickHref', ['$location', '$parse', ($location, $parse) ->
  ($scope, $elem, attr) ->
    $elem.click (e) ->
      firstI = $elem.find('i').first()
      if firstI.length
        firstI.addClass 'icon-spin icon-spinner'
      else
        $elem.html '<i class="icon-spin icon-spinner"></i> ' + $elem.html()

      # It's a callback; call the function.
      if attr.clickHref.indexOf('(') != -1
        $parse(attr.clickHref)($scope)
      else if attr.clickHref[0] == '#'
        $location.url(attr.clickHref.slice(1))
      else
        window.location = attr.clickHref
      e.preventDefault()
]
