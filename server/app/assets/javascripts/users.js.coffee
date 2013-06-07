gToggle = false

$(document).on 'ready page:load', () ->
  $('#btnSaveAndSubmit').click (e) ->
    e.preventDefault()
    $('#popoverNotConnected').show('slide')

  $('#btnSaveAndSubmitOk').click (e) ->
    e.preventDefault()
    $('#popoverNotConnected').hide('slide', ->
      Turbolinks.visit('/users/done')
    )

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

  $('#btnGeneratePolicyRequest').click (e) ->
    e.preventDefault()
    $('#popoverGeneratePolicyRequest').show('slide')

  $('#btnGeneratePolicyRequestOk').click (e) ->
    e.preventDefault()
    $('#btnGeneratePolicyRequest').html('<i class="icon-ok"></i> Generate Policy Request')
                                  .addClass('pure-button-disabled')
    $('#popoverGeneratePolicyRequest').hide('slide')

  $('#btnSaveAddMiscNote').click (e) ->
    $('#photoEmptyRecord').remove()
    $('#photoSampleRecord').show(500)

  $('#btnAddMiscNote, #btnSaveAddMiscNote, #btnCancelAddMiscNote').click (e) ->
    if gToggle
      $('#popoverAddMiscNote').hide('slide')
    else
      $('#popoverAddMiscNote').show('slide')
    gToggle = !gToggle

  $('#btnSaveAddPhoto').click (e) ->
    $('#photoEmptyRecord').remove()
    $('#photoSampleRecord').show(500)

  $('#btnAddPhoto, #btnSaveAddPhoto, #btnCancelAddPhoto').click (e) ->
    if gToggle
      $('#popoverAddPhoto').hide('slide')
    else
      $('#popoverAddPhoto').show('slide')
    gToggle = !gToggle
