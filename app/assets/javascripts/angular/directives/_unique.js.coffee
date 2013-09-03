App.directive 'unique', ['$parse', '$injector', ($parse, $injector) ->
  require: 'ngModel',
  link: ($scope, elem, attr, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      model = $scope.modelPath()
      root = $scope.root

      foundMatch = false

      # The model we're validating is part of a collection that is entered via modal.
      if model? && model != root
        for collectionElem in ($parse(model)($scope) || [])
          if collectionElem[attr.name] == viewValue || collectionElem[attr.name]?.value == viewValue
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
            if collectionElem[attr.name] == viewValue || collectionElem[attr.name]?.value == viewValue
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

          # Prepend a '__' to prevent it from overwriting anything we actually care about.
          dependency = '__' + dependency

          collection = dependencyClass.query {}, (->
            for collectionElem in (collection || [])
              $scope[dependency] = collectionElem
              modelValue = $parse('__' + root + '.' + attr.name)($scope)
              if modelValue == viewValue || modelValue?.value == viewValue
                foundMatch = true
                break
            # Destroy the dependency we added because it was only for $parse().
            delete $scope[dependency]

            ctrl.$setValidity 'unique', !foundMatch
          ),
          (->
          ),
          true # Local request only

      viewValue
]
