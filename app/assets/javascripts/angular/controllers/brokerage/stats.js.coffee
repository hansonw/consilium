App.controller 'BrokerageStatsCtrl', ['$scope', 'BrokerageStats', 'Auth',\
                                       ($scope, BrokerageStats, Auth) ->
  Auth.checkBroker()

  $scope.title.text = 'Brokerage Stats'
  $scope.loading = true
  $scope.stats = BrokerageStats.get(
    -> $scope.loading = false
  , -> $scope.loading = false
  )

  $scope.timeRanges = [
    {id: 'all', name: 'All time'},
    {id: 'day', name: 'Today'},
    {id: 'week', name: 'Past week'},
    {id: 'month', name: 'Past month'},
  ]
  $scope.timeRange = 'all'

  $scope.setTimeRange = (range) ->
    $scope.timeRange = range
]
