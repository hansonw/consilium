App.directive 'modalToggle', ['Modal', (Modal) ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      targetId = attr.modalToggle
      Modal.toggleModal(targetId)
      $scope[targetId] = {}
      e.preventDefault()

    if !$scope._modalDestructor
      $scope._modalDestructor = true
      $scope.$on('$destroy', -> $('body').removeClass('modal-active'))
]