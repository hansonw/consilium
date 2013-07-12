App.directive 'intelligentOther', ['$timeout', ($timeout)->
  ($scope, $elem, $attr) ->
    checkOther = (object) ->
      if object.owner == 'Other'
        alert object.owner.value.length

    $timeout (->
      collection = (($scope.client['autoSchedules'] ||= {}).value ||= [])
      alert object.owner for object in collection
      #alert $scope["client"].autoSchedules
      #alert $attr.ngModel
    ),20000
]