App.controller 'ClientsIndexCtrl', ['$scope', '$location', 'Client', ($scope, $location, Client) ->
  results_per_page = 20

  $scope.loading = false
  $scope.error = false
  $scope.query = ''
  $scope.resultStart = 0
  $scope.moreResults = false
  $scope.showAdvancedSearch = false

  $scope.clientClick = (clnt) ->
    $location.path('/clients/view/' + clnt )

  $scope.updateResults = (more) ->
    if more && ($scope.loading || !$scope.moreResults)
      return # Nothing to do here.

    # Query for one more than is required; if an extra exists, then a 'show more' needs to be displayed
    $scope.loading = true
    $scope.error = false
    $scope.resultStart = if more then $scope.resultStart + results_per_page else 0
    query_params =
      short: true, # indicates we should only fetch id/name/company
      start: $scope.resultStart,
      limit: results_per_page+1

    if $scope.showAdvancedSearch
      query_params.filter = $scope.filter
    else
      query_params.query = $scope.query

    clients = Client.query(query_params,
        ->
          $scope.moreResults = clients.length > results_per_page
          if more
            Array::push.apply($scope.clients, clients.slice(0, results_per_page))
          else
            $scope.clients = clients.slice(0, results_per_page)
          $scope.loading = false
      , ->
          $scope.error = true
          $scope.loading = false
    )

  # Can't pass updateResults directly: $watch passes other arguments automatically
  $scope.$watch('query', -> $scope.updateResults(false))
  $scope.$watch('showAdvancedSearch', -> $scope.updateResults(false))
  $scope.$watch('filter', (-> $scope.updateResults(false)), true)
]
