App.filter('startFrom', ->
  (input, start) ->
    input && input.slice(+start)
)

App.filter('range', ->
  (input) ->
    if input > 0 then (i for i in [1..input]) else []
)

App.directive 'pagination', [ ->
  ($scope, $elem, attr) ->
    model = attr.pagination
    limit = +attr.paginationLimit

    pagination = ($scope.pagination ||= {})
    pagination[model] =
      start: 0,
      limit: limit,
      pages: 0
      curPage: 0

    $scope.$watch model, ( ->
      if obj = $scope.$eval(model)
        pagination[model].pages = Math.ceil(obj.length / limit)
    ), true

    $scope.pageGetIndex = (model, index) ->
      index + pagination[model].curPage * pagination[model].limit

    $scope.prevPage = (model) ->
      if pagination[model].curPage
        $scope.gotoPage(model, pagination[model].curPage - 1)

    $scope.nextPage = (model) ->
      if pagination[model].curPage + 1 < pagination[model].pages
        $scope.gotoPage(model, pagination[model].curPage + 1)

    $scope.gotoPage = (model, index) ->
      pagination[model].curPage = index
      pagination[model].start = index * pagination[model].limit
]

App.directive 'paginator', ['$compile', ($compile) ->
  ($scope, $elem, attr) ->
    model = attr.paginator
    $elem.html("""
      <ul class="pure-paginator" data-ng-show="pagination['#{model}'].pages > 1">
        <li>
          <a class="pure-button pure-button-xsmall" data-ng-click="prevPage('#{model}')">&lt;</a>
        </li>
        <li data-ng-repeat="item in (pagination['#{model}'].pages | range)">
          <a class="pure-button pure-button-xsmall"
             data-ng-class="$index == pagination['#{model}'].curPage && 'pure-button-active'"
             data-ng-click="gotoPage('#{model}', $index)">
            {{ $index + 1 }}
          </a>
        </li>
        <li>
          <a class="pure-button pure-button-xsmall" data-ng-click="nextPage('#{model}')">&gt;</a>
        </li>
      </ul>
    """)
    $compile($elem.contents())($scope)
]
