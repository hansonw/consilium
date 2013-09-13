App.directive 'restrict', ['$parse', ($parse) ->
  restrict: 'A',
  require: 'ngModel',
  link: ($scope, $elem, attrs) ->
    $elem.on 'keypress', (e) ->
      val = ($elem.val() || '')
      char = String.fromCharCode(e.which)
      if char.match(///#{attrs.restrict}///)
        e.preventDefault()
]
