App.controller 'BrokerageIndexCtrl', ['$scope', 'Brokerage', 'Auth', 'Modal',\
                                      ($scope, Brokerage, Auth, Modal) ->
  Auth.checkLogin()

  $scope.brokerage = Brokerage.get()

  $scope.submitForm = ->
    if !$scope.saving && $scope.form.$dirty
      $scope.saving = true
      $scope.brokerage.$save((->
        $scope.saving = false
        $scope.form.$setPristine()),
      (-> $scope.saving = false))

  $scope.addContact = ->
    obj = $scope.contacts
    collection = ($scope.brokerage.contacts ||= [])

    if obj.$index?
      # Remove the index field and add it back
      collection[obj.$index] = obj
      delete obj.$index
    else
      collection.push(obj)

    $scope.form.$setDirty()
    Modal.toggleModal('contacts')

  $scope.editContact = (index) ->
    $scope.contacts = angular.copy($scope.brokerage.contacts[index])
    $scope.contacts.$index = index
    Modal.toggleModal('contacts')

  $scope.deleteContact = (index) ->
    $scope.brokerage.contacts.splice(index, 1)
    $scope.form.$setDirty()
]