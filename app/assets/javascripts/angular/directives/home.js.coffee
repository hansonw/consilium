App.directive 'eatClick', ->
  (scope, element, attrs) ->
    $(element).click((event) -> event.stopPropagation())
