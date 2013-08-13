class window.Util
  @_pad: (str, len) ->
    while str.length < len
      str = '0' + str
    return str

  @generateGUID: ->
    Date.now().toString(16) + @_pad(Math.floor(Math.random() * 1e9).toString(16), 9)

  @unixTimestamp: ->
    Math.floor(Date.now() / 1000)

  @increment: (value) ->
    # Find the last consecutive group of digits and increment it while preserving leading zeros.
    # This should handle most use cases (e.g. if suffixes or prefixes are used)
    matches = value.match(/[0-9]+/g)
    if matches?
      match = matches[matches.length-1]
      inc = @_pad(String(+match + 1), match.length)
      index = value.lastIndexOf(match)
      return value.slice(0, index) + inc + value.slice(index + match.length)
    else
      return ''
