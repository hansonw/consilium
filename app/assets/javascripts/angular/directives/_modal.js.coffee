App.directive 'modalToggle', ->
  ($scope, $elem, attr) ->
    $($elem).click (e) ->
      targetId = attr.modalToggle
      $('body').toggleClass('modal-active')
      setTimeout (->
        $(".modal[id~='modal-#{targetId}']").toggleClass('active')
        $scope[targetId] = {}
      ), 20
      e.preventDefault()

    if !$scope._modalDestructor
      $scope._modalDestructor = true
      $scope.$on('$destroy', -> $('body').removeClass('modal-active'))