App.directive 'animateSubsection', ->
  ($scope, $elem, $attr) ->
    $($elem.find('a.section-edit')).click (e) ->
      h_before = $elem.find('div.subsection-inner').height() + 76
      $elem.find('div.subsection-outer').css('height', h_before)
      h_after = $elem.height()
      $content = $elem.find('div.subsection-inner')
      $content.css('-webkit-transform', 'translate3d(0, -' + h_after + 'px ,0)')
      setInterval ( ->
            $content.css('-webkit-transform', 'translateY(' + 38 + 'px)')
            ), 1000