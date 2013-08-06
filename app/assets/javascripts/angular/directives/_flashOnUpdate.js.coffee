App.directive 'flashOnUpdate', ['$rootScope', 'Flash', ($rootScope, Flash) ->
  restrict: 'C',
  link: ($scope, elem, attrs) ->
    $scope.$on '$locationChangeStart', ->
      if Flash.get('flashCollection') == attrs.id
        flashId = Flash.get 'flashId'
        if $("tr[data-item-id='#{flashId}']").length
          type = Flash.get 'flashType'

          setTimeout (->
            $("tr[data-item-id='#{flashId}']").addClass "flash-#{type}"
          ), 500
          setTimeout (->
            $("tr[data-item-id='#{flashId}']").removeClass "flash-#{type}"
          ), 2000

          Flash.set 'flashCollection', undefined
          Flash.set 'flashId', undefined
          Flash.set 'flashType', undefined
]
