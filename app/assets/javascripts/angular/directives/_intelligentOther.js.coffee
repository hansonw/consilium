App.directive 'intelligentOther', ->
  options = []
  ($scope, $elem, $attr) ->

    model = $attr.dropdownOther.split "."
    modelLength = model.length
    collectionField = model[modelLength - 1]
    model.pop()

    modelCollection = model[model.length-1]

    $("." + collectionField + " option").each ->
      options.push $(this).val()

    selectHtml = $("." + collectionField).html()
    
    $("div#modal-" + modelCollection).bind 'modal-toggle', ->
      check = []
      $("." + collectionField).html(selectHtml)
      
      model = $attr.dropdownOther.split "."
      model.pop()
      modelFirst = model.shift()
      collection = $scope.client[modelFirst]
      currentValue = $scope[modelFirst]

      if model.length > 0
        for collectionModel in model
          collection = collection[collectionModel]
          currentValue = currentValue[collectionModel]

      collection = ((collection ||= {}).value ||= [])
      for field in collection then do (field) ->
        if not (field[collectionField] in options) and currentValue? and field[collectionField]? and not (field[collectionField] in check)
          $("." + collectionField + " option:last").before("<option value='" + field[collectionField] + "'>" + field[collectionField] + "</option>")
          check.push field[collectionField]

      if currentValue?
        $elem.val(currentValue[collectionField])
        if not (currentValue[collectionField] == 'Other')
          $elem.removeClass('other-dropdown')
          $elem.parent().find('input').attr('type', 'hidden')