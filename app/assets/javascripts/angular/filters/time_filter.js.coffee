App.filter 'time', [ ->
  (text) ->
    units = ["second", "minute", "hour"]
    denom = [60, 60, 60]

    time = parseInt(text) || 0
    for unit, i in units
      if time < denom[i] || i == units.length-1
        time = Math.round(time*100) / 100
        if time == 1
          return "#{time} #{unit}"
        return "#{time} #{unit}s"
      time = time / denom[i]
]
