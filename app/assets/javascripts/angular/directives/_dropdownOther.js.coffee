App.directive 'dropdownOther', ['$parse', ($parse) ->
  bindings = {}
  options = {}

  return ($scope, $elem, $attrs) ->
    model = $attrs.dropdownOther
    type = if $elem.is('select') then 'select' else 'input'
    form = $scope[$elem.parents('form').attr('name')]
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
          $parse(model).assign($scope, $elem.val())
          bindings[model]['select'].removeClass('other-dropdown')
          input.attr('type', 'hidden')
          input.val('')
        else
          $parse(model).assign($scope, $elem.val())
          bindings[model]['select'].addClass('other-dropdown')
          input.attr('type', 'text')
        form.$setDirty()
    else
      $elem.on 'input', ->
        select = bindings[model]['select']
        if select.val() == 'Other'
          if $elem.val() != ''
            $parse(model).assign($scope, $elem.val())
          else
            $parse(model).assign($scope, 'Other')
        form.$setDirty()
]
