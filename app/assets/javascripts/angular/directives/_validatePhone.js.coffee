App.directive 'validatePhone', ->
  require: 'ngModel'
  link: ($scope, $elem, $attr, $ctrl) ->
      phoneValidator = (viewValue)->
        phoneValid = (/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.test(viewValue))
        if phoneValid or !viewValue
          $ctrl.$setValidity('phone', true);
          viewValue
        else
          $ctrl.$setValidity('phone', false);
          undefined

      $ctrl.$parsers.push(phoneValidator)
      $ctrl.$formatters.push(phoneValidator)