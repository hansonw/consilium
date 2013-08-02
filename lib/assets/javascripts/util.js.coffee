Object.byString = ($scope, s) ->
  $scope.$eval (o) ->
    s = s.replace(/\[(\w+)\]/g, ".$1") # convert indexes to properties
    s = s.replace(/^\./, "") # strip a leading dot
    a = s.split(".")
    while a.length
      n = a.shift()
      if !(n of o)
        # XXX: This is really bad! We should evaluate anything between
        # square brackets instead of assuming that anything with "Id"
        # at the end is an index into a collection.
        if !!n.match /Id$/
          n = $scope[n]
        else if a.length == 0 || !!n.match /^\d+$/
          o[n] ||= []
        else
          o[n] ||= {}
      o = o[n]
    o

window.generateGUID = ->
  _pad = (str, len) ->
    while str.length < len
      str = '0' + str
    return str
  Date.now().toString(16) + _pad(Math.floor(Math.random() * 1e9).toString(16), 9)

window.unix_timestamp = ->
  Math.floor(Date.now() / 1000)
