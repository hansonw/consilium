App.directive 'modalToggle', ->
  ($scope, $elem) ->
    $($elem).click (e) ->
      targetId = $($elem).attr('href')
      targetId = targetId.substr(1, targetId.length)
      $('body').toggleClass('modal-active')
      setTimeout (->
        $('.modal[id~="' + targetId + '"]').toggleClass('active')
      ), 20
      e.preventDefault()
    if !$scope._modalDestructor
      $scope._modalDestructor = true
      $scope.$on('$destroy', -> $('body').removeClass('modal-active'))