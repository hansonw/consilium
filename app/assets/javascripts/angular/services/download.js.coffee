App.factory 'Download', [-> {
  downloadURL: (url, name) ->
    if downloader? # phonegap
      downloader.get({url: url, name: name})
    else
      window.location = url
  downloadDataURI: (data, name) ->
    if downloader?
      downloader.get({data: data, name: name})
    else
      window.open(data, '_blank')
}]
