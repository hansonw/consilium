App.directive 'scrollFix', ->
  ($scope, $elem, $attr) ->
    domElem = $($elem[0])
    win = $(window)
    scrollMargin = parseInt($attr.scrollMargin) || 30
    scrollFixMaxWidth = parseInt($attr.scrollFixMaxWidth) || 400
    offset = domElem.offset().top if domElem.is(':visible') and domElem.width() <= scrollFixMaxWidth

    win.bind 'scroll', ->
      return if not domElem.is(':visible') or domElem.width() > scrollFixMaxWidth

      offset = domElem.offset().top if !offset

      scrollTop = win.scrollTop()

      if scrollMargin + scrollTop >= offset and not domElem.data 'scroll-fixed'
        domElem.data 'scroll-fixed', true
        domElem.data 'scroll-fix-top', domElem.css 'top'
        domElem.data 'scroll-fix-right', domElem.css 'right'
        domElem.data 'scroll-fix-left', domElem.css 'left'
        paddingLeft = parseInt domElem.css 'padding-left'
        paddingRight = parseInt domElem.css 'padding-right'
        domElem.css 'top', scrollMargin
        domElem.css 'right', win.width() - domElem.offset().left - domElem.width() - paddingLeft - paddingRight
        domElem.css 'left', domElem.offset().left
        domElem.css 'position', 'fixed'
      else if scrollMargin + scrollTop < offset and domElem.data 'scroll-fixed'
        domElem.data 'scroll-fixed', false
        domElem.css 'top', domElem.data 'scroll-fix-top'
        domElem.css 'right', domElem.data 'scroll-fix-right'
        domElem.css 'left', domElem.data 'scroll-fix-left'
        domElem.css 'position', 'static'
