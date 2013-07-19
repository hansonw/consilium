App.directive 'intelligentOther', ->
  options = []
  ($scope, $elem, $attr) ->
    intelligentWorkings = (selectHtml, collectionField) ->
      check = []
      $("." + collectionField).html(selectHtml)

      model = $attr.dropdownOther.split "."
      preModel = $attr.model
      modelString = "client"
      modelCurrent = model.shift()
      if preModel != "null"
        modelString = preModel + "." + modelCurrent
      else
        modelString = "client." + modelCurrent

      currentValue = Object.byString($scope, modelCurrent) # Model for current modal in format client.modal_name
      collection = Object.byString($scope, modelString) # All models for current modal client.model.modal_name where model can be something like locationInfos.value[locationInfoId]
      collection = ((collection ||= {}).value ||= [])
      for field in collection then do (field) ->
        if currentValue? and field[collectionField]? and field[collectionField].value? and not (field[collectionField].value in options) and not (field[collectionField].value in check)
          $("." + collectionField + " option:last").before("<option value='" + field[collectionField].value + "'>" + field[collectionField].value + "</option>")
          check.push field[collectionField].value

      if currentValue? and currentValue[collectionField]? and currentValue[collectionField].value?
        $elem.val(currentValue[collectionField].value)
        if not (currentValue[collectionField].value == 'Other')
          $elem.removeClass('other-dropdown')
          $elem.parent().find('input').attr('type', 'hidden')
      else
        $elem.removeClass('other-dropdown')
        $elem.parent().find('input').attr('type', 'hidden')

    modalName = $attr.dropdownOther.split "." 
    modalLength = modalName.length
    collectionField = modalName[modalLength - 2]
    modalCollection = modalName[modalLength - 3]

    $("." + collectionField + " option").each ->
      options.push $(this).val()

    selectHtml = $("." + collectionField).html()
    
    $("div#modal-" + modalCollection).bind('modal-toggle', ->
      intelligentWorkings(selectHtml, collectionField)
    )
