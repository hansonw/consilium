App.directive 'dropdownOther', ->
  bindings = {}
  options = {}

  return ($scope, $elem, $attrs) ->
    model = $attrs.dropdownOther
    type = if $elem.is('select') then 'select' else 'input'
    (bindings[model] ||= {})[type] = $elem

    $scope.$watch model, (newVal) ->
      $.each $elem.find('option'), ->
        (options[model] ||= {})[$(this).val()] = true
      newVal ||= ''
      if newVal == 'Other'
        bindings[model]['select'].val('Other')
        bindings[model]['select'].addClass('other-dropdown')
        bindings[model]['input'].attr('type', 'text')
      else if !options[model]?[newVal]
        bindings[model]['select'].val('Other')
        bindings[model]['select'].addClass('other-dropdown')
        bindings[model]['input'].val(newVal)
        bindings[model]['input'].attr('type', 'text')
      else if newVal == '' && bindings[model]['select'].hasClass('other-dropdown')
        bindings[model]['select'].val('Other')
        bindings[model]['input'].val(newVal)
        bindings[model]['input'].attr('type', 'text')
      else
        bindings[model]['select'].val(newVal)
        bindings[model]['select'].removeClass('other-dropdown')
        bindings[model]['input'].attr('type', 'hidden')
        bindings[model]['input'].val('')

    if type == 'select'
      $.each $elem.find('option'), ->
        (options[model] ||= {})[$(this).val()] = true

      $elem.change ->
        input = bindings[model]['input']
        if $elem.val() != 'Other'
          $scope.$eval("#{model} = '#{$elem.val()}'")
          bindings[model]['select'].removeClass('other-dropdown')
          input.attr('type', 'hidden')
          input.val('')
        else
          $scope.$eval("#{model} = '#{$elem.val()}'")
          bindings[model]['select'].addClass('other-dropdown')
          input.attr('type', 'text')
    else
      $elem.on 'input', ->
        select = bindings[model]['select']
        if select.val() == 'Other'
          if $elem.val() != ''
            $scope.$eval("#{model} = '#{$elem.val()}'")
          else
            $scope.$eval("#{model} = 'Other'")
