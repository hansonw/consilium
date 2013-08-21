App.directive 'unique', ['$parse', '$injector', ($parse, $injector) ->
  require: 'ngModel',
  link: ($scope, elem, attr, ctrl) ->
    model = $(elem).closest('[data-collection]').data('collection')

    ctrl.$parsers.unshift (viewValue) ->
      foundMatch = false

      # The model we're validating is part of a collection that is entered via modal.
      if model?
        for collectionElem in $parse(model)($scope)
          if collectionElem[attr.name] == viewValue || collectionElem[attr.name]?.value == viewValue
            foundMatch = true
            break
        ctrl.$setValidity 'unique', !foundMatch
      # The model we're validating is part of a collection that is entered by other means (such as Create Client for clients).
      else
        rootModel = $(elem).closest('[auto-save]').attr('auto-save')
        dependency = rootModel.charAt(0).toUpperCase() + rootModel.slice(1)
        # Resolve the dependency to an actual class.
        dependency = $injector.get dependency
        collection = dependency.query {}, (->
          for collectionElem in collection
            if (collectionElem[attr.name] == viewValue || collectionElem[attr.name]?.value == viewValue) &&
               (collectionElem.id != $scope[rootModel].id)
              foundMatch = true
              break
          ctrl.$setValidity 'unique', !foundMatch
        ),
        (->
        ),
        true # Local request only

      viewValue
]
