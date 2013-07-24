App.directive 'clickHref', ['$location', ($location) ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      window.location = attr.clickHref
      e.preventDefault()
]
