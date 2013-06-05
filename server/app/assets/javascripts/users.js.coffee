$(document).on 'ready page:load', () ->
  #$('[data-toggle~="popover"]').popover()
  $('#btnAddClientContact').click (e) ->
    $('#popoverAddClientContact').slideDown('slow', 'linear')

  $('#clientContacts').on('click', '#btnSaveAddClientContact', (e) ->
    e.preventDefault()
    $('#clientContactsEmptyRecord').remove()
    $('#clientContactsSampleRecord').show(500)
    $('#btnAddClientContact').popover('hide')
  )

  $(window).scroll (e) ->
    $('#form-nav .nav').css(top: 60)

  $('#saveAndSubmitModal').on('hidden', ->
    Turbolinks.visit('/done')
  )
