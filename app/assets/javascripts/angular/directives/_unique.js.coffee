App.directive 'unique', ['$parse', '$injector', ($parse, $injector) ->
  require: 'ngModel',
  link: ($scope, elem, attr, ctrl) ->
    # Case-insensitive match
    match = (a, b) ->
      a?.toLowerCase() == b?.toLowerCase()

    ctrl.$parsers.unshift (viewValue) ->
      model = $scope.modelPath()
      root = $scope.root

      foundMatch = false

      # The model we're validating is part of a collection that is entered via modal.
      if model? && model != root
        for collectionElem in ($parse(model)($scope) || [])
          if match(collectionElem[attr.name]?.value || collectionElem[attr.name], viewValue)
            foundMatch = true
            break
        ctrl.$setValidity 'unique', !foundMatch
      # The model we're validating is part of a collection that is entered by other means (such as Create Client for clients).
      else
        # Iterating over a collection within the current model. Don't request any new objects.
        re = /\[(.*)?\]/
        if !!root.match re
          unqualified_root = root.replace re, ''
          for collectionElem in ($parse(unqualified_root)($scope) || [])
            if match(collectionElem[attr.name]?.value || collectionElem[attr.name], viewValue)
              foundMatch = true
              break
          ctrl.$setValidity 'unique', !foundMatch
        # Check over a collection of root objects. We must request the full list and iterate through them.
        else
          # Figure out what dependent service we need to make the request with. This can be "Client", "User", etc.
          dependency = $(elem).closest('[auto-save]').attr('auto-save')
          dependencyClass = dependency.charAt(0).toUpperCase() + dependency.slice(1)
          # Resolve the dependency to an actual class.
          dependencyClass = $injector.get dependencyClass

          collection = dependencyClass.query {}, (->
            id = $parse(model)($scope)?.id
            for collectionElem in (collection || [])
              modelValue = $parse(attr.name)(collectionElem)
              if collectionElem.id != id # Allow changing name back to original
                if match(modelValue?.value || modelValue, viewValue)
                  foundMatch = true
                  break

            ctrl.$setValidity 'unique', !foundMatch
          ),
          (->
          ),
          true # Local request only

      viewValue
]
