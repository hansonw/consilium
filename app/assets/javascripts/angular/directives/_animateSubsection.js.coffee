App.directive 'animateSubsection', ['$timeout', ($timeout)->
  ($scope, $elem, $attr) ->
    applyTranslate = (element, yValue) ->
      element.css '-webkit-transform', 'translate3d(0, ' + yValue + 'px, 0)'
      element.css 'transform', 'translate3d(0, ' + yValue + 'px, 0)'

    applyScale = (element, scaleValue) ->
      element.css '-webkit-transform', 'scale3d(1, ' + scaleValue + ', 1)'
      element.css 'transform', 'scale3d(1, ' + scaleValue + ', 1)'

    pushElements = (height, animate) ->
      #Move all elements below up or down depending on height value
      $.each $elem.nextAll(), ->
          $(this).data 'offset', off_ = ($(this).data('offset') or 0) + height
          if animate
            applyAnimate $(this), true
          else
            applyAnimate $(this)
          applyTranslate $(this), off_

    applyAnimate = (element, type) ->
      if type
        element.addClass 'transitionOn'
      else
        element.removeClass 'transitionOn'

    # TODO: Unify constants used here with ones used in CSS.
    transitionDuration = 0.4 # Obtained from stylesheets/shared/_utilities.css.scss, transition() mixin
    padding = 20 # Padding around well, obtained from stylesheets/shared/consillium.css.scss
    conversionFactor = 1200 # seconds to miliseconds plus buffer of 20%
    heightOriginal = $elem.height()
    
    div = $elem.find '.slider'
    outer = $elem.find '.subsection-outer'
    inner = outer.find '.subsection-inner'
    contents = inner.find '.subsection-contents'

    applyAnimate contents, false
    applyTranslate contents, '-' + (contents.height() + padding)
    # XXX:  Only problem with this is if you move it too fast, the elements dont move to the right spot.
    $(window).resize ->
      if !$elem.hasClass 'active'
        applyAnimate contents, 'none'
        applyTranslate contents, '-' + (contents.height() + padding)
      else
        height = contents.height() + padding
        scaleAmount = 1 + height / div.outerHeight()
        applyAnimate div, false
        applyScale div, scaleAmount

        applyAnimate contents, false
        applyTranslate contents, 0
        $elem.height heightOriginal + height

    $($elem.find 'a.section-edit').click ->
      height = contents.height() + padding

      if $elem.hasClass 'active'
        $elem.removeClass 'active'

        applyAnimate contents, true
        applyTranslate contents, -height

        applyAnimate div, true
        applyScale div, 1

        pushElements -height, true
        # Undo tranforms and add heights
        $timeout () ->
          applyAnimate $elem, false
          $elem.height heightOriginal
          pushElements height
        , transitionDuration * conversionFactor
      else
        scaleAmount = 1 + height / div.outerHeight()
        applyAnimate div, true
        applyScale div, scaleAmount

        applyAnimate contents, true
        applyTranslate contents, 0

        pushElements height, true
        # Undo tranforms and add heights
        $timeout () ->
          applyAnimate $elem, false
          $elem.height heightOriginal + height
          pushElements -height
        , transitionDuration * conversionFactor

        $elem.addClass 'active', !$elem.hasClass 'active'
]