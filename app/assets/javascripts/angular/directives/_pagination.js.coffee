App.filter('startFrom', ->
  (input, start) ->
    input && input.slice(+start)
)

App.filter('range', ->
  (input) ->
    if input > 0 then (i for i in [1..input]) else []
)

App.directive 'pagination', ['$parse', ($parse) ->
  ($scope, $elem, attr) ->
    model = attr.pagination
    limit = +attr.paginationLimit

    $scope.pagination =
      start: 0,
      limit: limit,
      pages: 0
      curPage: 0

    $scope.$watch model, (newVal, oldVal) ->
      $scope.pagination.pages = Math.ceil(newVal?.length / limit)
      if $scope.pagination.pages > 0 && $scope.pagination.curPage >= $scope.pagination.pages
        $scope.gotoPage($scope.pagination.pages - 1)
    , true

    $scope.pageGetIndex = (index) ->
      index + $scope.pagination.curPage * $scope.pagination.limit

    $scope.prevPage = ->
      if $scope.pagination.curPage
        $scope.gotoPage($scope.pagination.curPage - 1)

    $scope.nextPage = ->
      if $scope.pagination.curPage + 1 < $scope.pagination.pages
        $scope.gotoPage($scope.pagination.curPage + 1)

    $scope.gotoPage = (index) ->
      $scope.pagination.curPage = index
      $scope.pagination.start = index * $scope.pagination.limit
]

App.directive 'paginator', ['$compile', ($compile) ->
  ($scope, $elem, attr) ->
    $elem.html("""
      <ul class="pure-paginator" data-ng-show="pagination.pages > 1">
        <li>
          <a class="pure-button pure-button-xsmall" data-ng-click="prevPage()">&lt;</a>
        </li>
        <li data-ng-repeat="item in (pagination.pages | range)">
          <a class="pure-button pure-button-xsmall"
             data-ng-class="$index == pagination.curPage && 'pure-button-active'"
             data-ng-click="gotoPage($index)">
            {{ $index + 1 }}
          </a>
        </li>
        <li>
          <a class="pure-button pure-button-xsmall" data-ng-click="nextPage()">&gt;</a>
        </li>
      </ul>
    """)
    $compile($elem.contents())($scope)
]
