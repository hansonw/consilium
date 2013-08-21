App.directive 'unique', ['$parse', ($parse) ->
  require: 'ngModel',
  link: ($scope, elem, attr, ctrl) ->
    model = $(elem).closest('[data-collection]').data('collection')

    ctrl.$parsers.unshift (viewValue) ->
      foundMatch = false

      for collectionElem in $parse(model)($scope)
        if collectionElem[attr.name] == viewValue
          foundMatch = true
          break

      ctrl.$setValidity 'unique', !foundMatch
      viewValue
]
