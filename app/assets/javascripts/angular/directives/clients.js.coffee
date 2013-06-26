App.directive 'advancedSearch', ->
  ($scope, $elem, $attr) ->
    domElem = $($elem[0])
    domElem.find('a.advanced-search-btn').bind 'click', (e) ->
      domElem.toggleClass 'active'
      domElem.find('i').toggleClass('icon-caret-down icon-caret-up')
      $scope.showAdvancedSearch = !$scope.showAdvancedSearch
      $scope.$apply