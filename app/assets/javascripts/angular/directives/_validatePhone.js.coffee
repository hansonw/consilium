App.directive 'validatePhone', ->
  require: 'ngModel'
  link: ($scope, $elem, $attr, $ctrl) ->
    phoneValidator = (viewValue) ->
      phoneValid = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.test viewValue
      if phoneValid or !viewValue
        $ctrl.$setValidity 'phone', true
      else
        $ctrl.$setValidity 'phone', false
      # NOTE: this binds with the model even if validation fails
      # however, it makes things stick around in the modal otherwise
      return viewValue

    $ctrl.$parsers.push phoneValidator
    $ctrl.$formatters.push phoneValidator