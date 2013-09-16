App.filter 'permissions', [ ->
  (text, isFullList = true) ->
    permissions =
      if isFullList
        [
          'None',
          'Client',
          'Broker',
          'Administrator',
        ]
      else
        [
          'None',
          'Can manage',
        ]

    permission = parseInt(text)
    permission = 0 if isNaN(permission)
    return permissions[permission]
]
