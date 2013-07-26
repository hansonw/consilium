App.directive 'scrollFix', ->
  ($scope, $elem, $attr) ->
    domElem = $($elem[0])
    win = $(window)
    scrollFixMargin = parseInt($attr.scrollFixMargin) || 30
    offset = domElem.offset().top if domElem.is(':visible')
    origHeight = null

    win.bind 'scroll resize', ->
      return if not domElem.is(':visible')
      origHeight = domElem.height() if !origHeight?
      scrollFixCondition = Modernizr.mq($attr.scrollFixCondition || 'screen and (min-width:0)')
      wasScrollFixCondition = domElem.data 'scroll-fix-condition'

      offset = domElem.offset().top if !offset

      scrollTop = win.scrollTop()

      if not scrollFixCondition and domElem.data 'scroll-fixed'
        domElem.data 'scroll-fixed', false
        domElem.removeAttr 'style'
      else if scrollFixCondition and scrollFixMargin + scrollTop >= offset and not domElem.data 'scroll-fixed'
        scrollFixTime = 500 if not wasScrollFixCondition

        setTimeout ( ->
          domElem.data 'scroll-fixed', true

          paddingLeft = parseInt(domElem.css 'padding-left')
          paddingRight = parseInt(domElem.css 'padding-right')
          paddingBottom = parseInt(domElem.css 'padding-bottom')

          domElem.css 'top', scrollFixMargin
          domElem.css 'width', domElem.parent().width() - paddingLeft - paddingRight
          domElem.css 'left', domElem.offset().left
          domElem.css 'position', 'fixed'
          domElem.css 'max-height', origHeight + paddingBottom
        ), scrollFixTime
      else if scrollFixMargin + scrollTop < offset and domElem.data 'scroll-fixed'
        domElem.data 'scroll-fixed', false
        domElem.removeAttr 'style'

      domElem.data 'scroll-fix-condition', scrollFixCondition
