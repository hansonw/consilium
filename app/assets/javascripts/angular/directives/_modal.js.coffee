App.directive 'modalToggle', ->
  ($scope, $elem) ->
    $($elem).click (e) ->
      targetId = $($elem).attr('href')
      targetId = targetId.substr(1, targetId.length)
      $('.modal[id~="' + targetId + '"]').toggleClass('active')
      $('body').toggleClass('modal-active')
      e.preventDefault()
