App.directive 'toggle', ->
  ($scope, elem, attr) ->
    id = attr.toggle
    elem.on 'click', ->
      $("##{id}").toggle()
