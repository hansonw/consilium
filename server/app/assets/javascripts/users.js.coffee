gToggle = false

$(document).on 'ready page:load', () ->
  #$('[data-toggle~="popover"]').popover()
  $('#btnAddClientContact, #btnSaveAddClientContact, #btnCancelAddClientContact').click (e) ->
    if gToggle
      $('#popoverAddClientContact').hide('slide')
    else
      $('#popoverAddClientContact').show('slide')
    gToggle = !gToggle
    e.preventDefault()

# $('#clientContacts').on('click', '#btnSaveAddClientContact', (e) ->
#   e.preventDefault()
#   $('#clientContactsEmptyRecord').remove()
#   $('#clientContactsSampleRecord').show(500)
#   $('#btnAddClientContact').popover('hide')
# )

  $(window).scroll (e) ->
    $('#form-nav .nav').css(top: 60)

  $('#saveAndSubmitModal').on('hidden', ->
    Turbolinks.visit('/done')
  )
