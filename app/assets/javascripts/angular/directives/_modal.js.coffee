App.directive 'modalToggle', ['Modal', (Modal) ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      targetId = attr.modalToggle
      Modal.toggleModal(targetId)
      # Preserve the original object; could be referred to by a writeNode
      angular.copy($scope[targetId], {})
      $scope[targetId + 'Form']?.$setPristine()?
      e.preventDefault()

    if !$scope._modalDestructor
      $scope._modalDestructor = true
      $scope.$on('$destroy', -> Modal.toggleModal(null, false))
]
