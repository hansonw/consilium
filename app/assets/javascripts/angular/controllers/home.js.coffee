App.controller 'HomeController', ['$scope', ($scope) ->
  $scope._curMenuItem = ''
  $scope._curSubMenuItem = ''

  $scope.menuItems = [
    name: 'Clients'
    link: '/clients'
    subMenuItems: [
      name: 'Create Client'
      link: '/new'
    ,
      name: 'Find Client'
      link: '/find'
    ,
      name: 'Remove Client'
      link: '/delete'
    ]
  ,
    name: 'Documents'
    link: '/documents'
    subMenuItems: [
      name: 'Recent Changes'
      link: '/recent'
    ,
      name: 'Client Document History'
      link: '/history'
    ,
      name: 'Generate Policy Request'
      link: '/request'
    ]
  ]

  $scope.selectMenuItem = (name) ->
    if $scope.menuItemIsSelected(name)
      $scope._curMenuItem = ''
    else
      $scope._curMenuItem = name

  $scope.menuItemIsSelected = (name) ->
    return $scope._curMenuItem == name

  $scope.selectSubMenuItem = (name) ->
    if $scope.subMenuItemIsSelected(name)
      $scope._curSubMenuItem = ''
    else
      $scope._curSubMenuItem = name

  $scope.subMenuItemIsSelected = (name) ->
    return $scope._curSubMenuItem == name
]
