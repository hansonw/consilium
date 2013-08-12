window.generateGUID = ->
  _pad = (str, len) ->
    while str.length < len
      str = '0' + str
    return str
  Date.now().toString(16) + _pad(Math.floor(Math.random() * 1e9).toString(16), 9)

window.unix_timestamp = ->
  Math.floor(Date.now() / 1000)
