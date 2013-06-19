#<% require 'angular_assets' %>

App.directive 'modalToggle', ->
# restrict: 'E'
# replace: true
# scope: {
#   href: '='
#   text: '='
# }
# template: '<a href="{{ href }}" data-ng-click="toggleModal()">{{ text }}</a>'
# controller: ($scope, $element, $attrs, $location) ->
#   $scope.toggleModal = ->
#     targetId = $scope.href.substr(0, $scope.href.length)
#     alert targetId
#     alert $('.modal[id~="' + targetId + '"]')

  ($scope, $elem) ->
    $($elem).click (e) ->
      console.log(e)
      e.preventDefault()
