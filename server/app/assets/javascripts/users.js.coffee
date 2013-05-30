$(document).on 'ready page:load', () ->
  #$('[data-toggle~="popover"]').popover()
  $('#btnAddClientContact').popover(
    html: true
    placement: 'left'
    content: ->
      $('#popoverAddClientContact').html()
  )

  $('#clientContacts').on('click', '#btnSaveAddClientContact', (e) ->
    e.preventDefault()
    $('#clientContactsEmptyRecord').remove()
    $('#clientContactsSampleRecord').show(500)
    $('#btnAddClientContact').popover('hide')
  )

  $('#form-nav a').click (e) ->
    $('#form-nav .nav').css(top: 50)
