App.directive 'modalToggle', ['Modal', (Modal) ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      targetId = attr.modalToggle
      $scope[targetId] = {}
      $scope[targetId + 'Form']?.$setPristine()?
      Modal.toggleModal(targetId)
      e.preventDefault()

    if !$scope._modalDestructor
      $scope._modalDestructor = true
      $scope.$on('$destroy', -> Modal.toggleModal(null, false))
]
