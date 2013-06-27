App.service 'RecentClients', [->
  clients = []
  try clients = angular.fromJson(window.localStorage.getItem('RecentClients')) || []

  return {
    limit: 10,
    clients: clients,
    logClientShow: (client) ->
      for val, index in @clients
        if val.id == client.id
          @clients.splice(index, 1)
          break
      @clients.splice(0, 0, {
        id: client.id,
        name: client.name?.value,
        company: client.company?.value,
      })
      @clients = @clients.splice(0, @limit)
      window.localStorage.setItem('RecentClients', angular.toJson(@clients))
  }
]
