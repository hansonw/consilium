gToggle = false

$(document).on 'ready page:load', () ->
  #$('[data-toggle~="popover"]').popover()

  $('#btnSaveAddClientContact').click (e) ->
    $('#clientContactsEmptyRecord').remove()
    $('#clientContactsSampleRecord').show(500)
    e.preventDefault()

  $('#btnAddClientContact, #btnSaveAddClientContact, #btnCancelAddClientContact').click (e) ->
    if gToggle
      $('#popoverAddClientContact').hide('slide')
    else
      $('#popoverAddClientContact').show('slide')
    gToggle = !gToggle

  $('#saveAndSubmitModal').on('hidden', ->
    Turbolinks.visit('/done')
  )
