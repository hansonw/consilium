App.factory 'Modal', [->
  toggleModal: (modalName, setMode) ->
    if !setMode? && !$('body').hasClass('modal-active') || setMode
      # Huge hack to avoid 'shifting' content when scrollbar disappears.
      # WILL BREAK IF BODY HAS PADDING SET ELSEWHERE.
      width = $('body').prop('clientWidth')
      $('body').addClass('modal-active')
      newWidth = $('body').prop('clientWidth')
      $('body, #toolbar').css('padding-right', newWidth - width)
    else
      $('body').removeClass('modal-active')
      $('body, #toolbar').css('padding-right', 0)

    if modalName
      $(".modal[id~='modal-#{modalName}']").toggleClass('active', setMode)
]
