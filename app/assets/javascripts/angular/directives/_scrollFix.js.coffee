App.directive 'scrollFix', ->
  ($scope, $elem, $attr) ->
    win = $(window)
    scrollFixMargin = parseInt($attr.scrollFixMargin) || 30
    offset = $elem.offset().top if $elem.is(':visible')
    origHeight = null

    win.on 'scroll resize', handler = ->
      return if not $elem.is(':visible')
      origHeight = $elem.height() if !origHeight?
      scrollFixCondition = Modernizr.mq($attr.scrollFixCondition || 'screen and (min-width:0)')
      wasScrollFixCondition = $elem.data 'scroll-fix-condition'

      offset = $elem.offset().top if !offset

      scrollTop = win.scrollTop()

      if not scrollFixCondition and $elem.data 'scroll-fixed'
        $elem.data 'scroll-fixed', false
        $elem.removeAttr 'style'
      else if scrollFixCondition and scrollFixMargin + scrollTop >= offset and not $elem.data 'scroll-fixed'
        scrollFixTime = 500 if not wasScrollFixCondition

        setTimeout ( ->
          $elem.data 'scroll-fixed', true

          paddingLeft = parseInt($elem.css 'padding-left')
          paddingRight = parseInt($elem.css 'padding-right')
          paddingBottom = parseInt($elem.css 'padding-bottom')

          $elem.css 'top', scrollFixMargin
          $elem.css 'width', $elem.parent().width() - paddingLeft - paddingRight
          $elem.css 'left', $elem.offset().left
          $elem.css 'position', 'fixed'
          $elem.css 'max-height', origHeight + paddingBottom
        ), scrollFixTime
      else if scrollFixMargin + scrollTop < offset and $elem.data 'scroll-fixed'
        $elem.data 'scroll-fixed', false
        $elem.removeAttr 'style'

      $elem.data 'scroll-fix-condition', scrollFixCondition

    $scope.$on '$destroy', ->
      win.off 'scroll resize', handler
