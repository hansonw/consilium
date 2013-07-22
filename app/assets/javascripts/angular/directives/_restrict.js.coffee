App.directive 'restrict', ['$parse', ($parse) ->
  restrict: 'A',
  require: 'ngModel',
  link: ($scope, elem, attrs) ->
    elem.on 'input', ->
      $parse(attrs.ngModel).assign $scope, elem.val().replace(///#{attrs.restrict}///g, '')
]
