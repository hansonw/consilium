App.directive 'phone', ->
	require: 'ngModel'
	link: ($scope, $elem, $attr, $ctrl) ->
		
      phoneValidator = (viewValue)->
        phoneValid = (/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.test(viewValue))
        if !phoneValid
          $ctrl.$setValidity('clientContacts.phone', false);
          undefined
        else
          $ctrl.$setValidity('clientContacts.phone', true);
          viewValue
      $ctrl.$parsers.push(phoneValidator)
      $ctrl.$formatters.push(phoneValidator)