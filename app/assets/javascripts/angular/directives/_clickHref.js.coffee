App.directive 'clickHref', ['$location', ($location) ->
  ($scope, $elem, attr) ->
    $elem.click (e) ->
      if attr.clickHref[0] == '#'
        $location.url(attr.clickHref.slice(1))
      else
        window.location = attr.clickHref
      e.preventDefault()
]
