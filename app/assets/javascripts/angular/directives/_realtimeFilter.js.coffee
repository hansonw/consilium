App.directive 'realtimeFilter', ['$parse', ($parse) ->
  filters =
    name:
      apply: (text) ->
        text.replace /\w\S*/g, (txt) ->
          txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
      unapply: (text) ->
        text

  restrict: 'A',
  require: 'ngModel',
  link: ($scope, elem, attrs, ngModel) ->
    $scope.$watch attrs.ngModel, ->
      val = elem.val()
      filter = filters[attrs.realtimeFilter]
      $parse(attrs.ngModel).assign($scope, filter.unapply(val))
      elem.val(filter.apply(val))
]
