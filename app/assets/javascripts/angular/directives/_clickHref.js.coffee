App.directive 'clickHref', ['$location', ($location) ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      if !$($elem).find('.link:hover').length and !$($elem).find('.pure-button:hover').length
        if attr.clickHref[0] == '#'
          $location.path(attr.clickHref.slice(1))
        else
          window.location = attr.clickHref
        e.preventDefault()
]