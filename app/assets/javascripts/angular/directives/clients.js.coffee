App.directive 'advancedSearch', ->
  ($scope, $elem, $attr) ->
    domElem = $($elem[0])
    domElem.find('a.advanced-search-btn').bind 'click', (e) ->
      domElem.toggleClass 'active'
      domElem.find('i').toggleClass('icon-caret-right icon-caret-down')

