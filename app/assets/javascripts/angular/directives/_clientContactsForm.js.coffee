App.directive 'clientContactsForm', [ ->
  ($scope, elem, attrs) ->
    $scope.client_contacts ||= {}

    $scope.toggleAccount = ->
      if confirm \
        (if $scope.writeNode.client_contacts.user
          "Clicking OK will make #{($scope.client_contacts.name || {value: 'this contact'}).value} " +
          "unable to manage #{($scope.client.company_name || {value: 'this client'}).value}. " +
          "Are you sure you want to do this?"
        else
          "Clicking OK will give #{($scope.client_contacts.name || {value: 'this contact'}).value} " +
          "permission to manage #{($scope.client.company_name || {value: 'this client'}).value}. " +
          "They will be sent an email with instructions. Are you sure you want to do this?")

        $scope.writeNode.client_contacts.user = !$scope.writeNode.client_contacts.user
]
