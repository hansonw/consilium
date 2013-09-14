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

    $scope.submitClientContacts = ->
      if $scope.writeNode.client_contacts.user == true # Must check equality or we may overwrite an existing user
        contact = $scope.writeNode.client_contacts
        $scope.writeNode.client_contacts.user =
          id: Util.generateGUID()
          name: contact.name.value
          email: contact.email.value
      else if $scope.writeNode.client_contacts.user == false
        delete $scope.writeNode.client_contacts.user
      else # Must be an object (an actual user)
        contact = $scope.writeNode.client_contacts
        # Propagate the contact's information to the user.
        $scope.writeNode.client_contacts.user.name = contact.name.value
        $scope.writeNode.client_contacts.user.email = contact.email.value

      $scope.saveField()
]
