App.directive 'clickHref', ['$location', ($location) ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      $location.path(attr.clickHref)
      e.preventDefault()
]