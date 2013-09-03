App.directive 'dropdownOther', ['$parse', ($parse) ->
  return ($scope, $elem, $attrs) ->
    bindings = ($scope._dropdownBindings ||= {})
    options = ($scope._dropdownOptions ||= {})

    model = $attrs.dropdownOther
    type = if $elem.is('select') then 'select' else 'input'
    form = $scope[$elem.parents('form').attr('name')]
    (bindings[model] ||= {})[type] = $elem

    setValidity = (val) ->
      if $attrs.required
        form.$setValidity('required', val != '', ctrl)

    if type == 'select'
      $scope.$watch model, (newVal, oldVal) ->
        options[model] = {}
        $.each $elem.find('option'), ->
          options[model][$(this).val()] = true

        if newVal == 'Other'
          bindings[model]['select'].val('Other')
          bindings[model]['select'].addClass('other-dropdown')
          bindings[model]['input'].attr('type', 'text')
        else if newVal? && !options[model]?[newVal]
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

      $.each $elem.find('option'), ->
        (options[model] ||= {})[$(this).val()] = true

      # HACK: this doesn't actually exist in the form. Angular only checks the $name, so create a fake control
      ctrl = {$name: $elem.attr('name')}
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

        setValidity($elem.val())
        form.$setDirty()

      setValidity($parse(model)($scope))
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
