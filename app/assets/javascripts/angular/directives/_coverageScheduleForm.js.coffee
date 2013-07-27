App.directive 'coverageScheduleForm', ['$parse', 'Modal', ($parse, Modal) ->
  ($scope, elem, attrs) ->
    # TODO: figure out a better way to put this in.

    coverageIdLookup = {}
    for cat, name of $scope.coverageCategories
      coverageIdLookup[name] = {}
      for type, typename of $scope.coverageTypes[cat]
        coverageIdLookup[name][typename] = [cat, type]

    form = attrs.coverageScheduleForm
    model = attrs.coverageScheduleModel
    obj = $parse(form)
    store = $parse(model)

    $scope.saveCoverageSchedules = ->
      coverageSchedules = obj($scope) || {}
      collection = []
      for cat, data of coverageSchedules
        for type, coverage of data
          collection.push(
            category: {value: $scope.coverageCategories[cat]},
            type: {value: $scope.coverageTypes[cat][type]},
            subtype: coverage.subtype,
            replacementCost: coverage.replacementCost,
            coinsurance: coverage.coinsurance,
            deductible: coverage.deductible,
            limit: coverage.limit
          )
      store.assign($scope, collection)
      $scope.clientForm.$setDirty()
      Modal.toggleModal(form)
      $scope.saveForm(false)

    $scope.editCoverageSchedule = (index) ->
      collection = store($scope) || {}
      coverageSchedules = {}
      for coverage, i in collection
        ids = coverageIdLookup[coverage.category.value][coverage.type.value]
        (coverageSchedules[ids[0]] ||= {})[ids[1]] =
          subtype: coverage.subtype,
          replacementCost: coverage.replacementCost,
          coinsurance: coverage.coinsurance,
          deductible: coverage.deductible,
          limit: coverage.limit

        if i == index
          $scope.coverage =
            category: coverage.category.value,
            type: coverage.type.value

      obj.assign($scope, coverageSchedules)
      Modal.toggleModal(form)

    $scope.clearCoverage = ->
      coverageSchedules = obj($scope) || {}
      cat = coverageIdLookup[$scope.coverage.category]?[$scope.coverage.type]
      if coverageSchedules[cat[0]]?[cat[1]]?
        delete coverageSchedules[cat[0]][cat[1]]
        if $.isEmptyObject(coverageSchedules[cat[0]])
          delete coverageSchedules[cat[0]]
      obj.assign($scope, coverageSchedules)
]
