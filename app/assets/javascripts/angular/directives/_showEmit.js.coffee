# Equivalent to ng-show, but emits a showEmit event to the $scope on state change.
App.directive 'showEmit', ->
  ($scope, elem, attrs) ->
    $scope.$watch attrs.showEmit, (newVal, oldVal) ->
      if newVal
        elem.show()
      else
        elem.hide()
      $scope.$emit('showEmit')
