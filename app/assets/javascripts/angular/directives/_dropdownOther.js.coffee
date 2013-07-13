App.directive 'dropdownOther', ['$timeout', ($timeout)->
  ($scope, $elem, $attr) ->
    $timeout (-> # cant find a way to run this on loading modal/showing section
      model = $attr.ngModel.replace('dropdown','');
      #alert model
      currentValue = 'Company'
      inDropDown = false
      $elem.find('option').each( ->
        if $(this).val() == currentValue
            #modeldropdown = currentValue Something along the lines of that
            inDropDown = true
      )
      #modelother = currentValue
    ),1000
]