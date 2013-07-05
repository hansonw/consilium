App.directive 'validatePhone', ->
  require: 'ngModel'
  link: ($scope, $elem, $attr, $ctrl) ->
    phoneValidator = (returnValue) -> (viewValue) ->
      phoneValid = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.test viewValue
      if phoneValid or !viewValue
        $ctrl.$setValidity 'phone', true
        viewValue
      else
        $ctrl.$setValidity 'phone', false
        if returnValue then viewValue else undefined

    $ctrl.$parsers.push phoneValidator(false)
    $ctrl.$formatters.push phoneValidator(true)