App.directive 'animateSubsection', ['$timeout', '$rootScope', ($timeout, $rootScope)->
  ($scope, $elem, $attr) ->
    applyTranslate = (element, yValue) ->
      element.css '-webkit-transform', 'translate3d(0, ' + yValue + 'px, 0)'
      element.css 'transform', 'translate3d(0, ' + yValue + 'px, 0)'

    applyScale = (element, scaleValue) ->
      element.css '-webkit-transform', 'scale3d(1, ' + scaleValue + ', 1)'
      element.css 'transform', 'scale3d(1, ' + scaleValue + ', 1)'

    pushElements = (offset, animate = false, relative = true) ->
      #Move all elements below up or down depending on height value
      $.each $elem.nextAll(), ->
        $(this).data('offset', off_ = (relative && $(this).data('offset') || 0) + offset)
        if animate
          applyAnimate $(this), true
        else
          applyAnimate $(this), false
        applyTranslate $(this), off_

    applyAnimate = (element, type) ->
      if type
        element.addClass 'transitionOn'
      else
        element.removeClass 'transitionOn'

    toggleSectionExpanded = (disableTransition = false) ->
      if $scope.timer
        $timeout.cancel($scope.timer)
        $scope.timer = null

      if $elem.hasClass 'active'
        height = contents.height() + padding

        applyAnimate contents, !disableTransition
        applyTranslate contents, -height

        applyAnimate div, !disableTransition
        applyScale div, 1

        pushElements -height, !disableTransition
        # Undo tranforms and add heights
        $scope.timer = $timeout () ->
          applyAnimate $elem, false
          $elem.height heightOriginal
          pushElements 0, false, false
          inner.hide()
        , transitionDuration * conversionFactor
      else
        if !inner.is(':visible')
          inner.show()
          height = contents.height() + padding
          applyAnimate contents, false
          applyTranslate contents, -height
        else
          height = contents.height() + padding

        scaleAmount = 1 + height / div.outerHeight()
        applyAnimate div, !disableTransition
        applyScale div, scaleAmount

        applyAnimate contents, !disableTransition
        applyTranslate contents, 0

        pushElements height, !disableTransition
        # Undo tranforms and add heights
        $scope.timer = $timeout () ->
          applyAnimate $elem, false
          $elem.height heightOriginal + height
          pushElements 0, false, false
        , transitionDuration * conversionFactor

      $elem.toggleClass 'active'

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

    $rootScope.$on '$viewContentLoaded', ->
      sectionStartsOpen = $elem.hasClass 'startOpen'

      # Keep checking if the section has loaded and, when it has, expand it.
      expandStartOpenSection = ->
        if inner.height() == 0
          $timeout (->
            expandStartOpenSection()
          ), 200
          null
        else
          toggleSectionExpanded(true)

      if sectionStartsOpen
        $timeout (->
          expandStartOpenSection()
        ), 0
        null
      else
        applyTranslate contents, -(contents.height() + padding)

    # XXX:  Only problem with this is if you move it too fast, the elements dont move to the right spot.
    updateElement = ->
      if $elem.hasClass 'active'
        height = contents.height() + padding
        scaleAmount = 1 + height / div.outerHeight()
        applyAnimate div, false
        applyScale div, scaleAmount

        applyAnimate contents, false
        applyTranslate contents, 0
        $elem.height heightOriginal + height

    $(window).resize updateElement
    $scope.$watch 'client', updateElement, true

    $($elem.find 'a.section-edit').click ->
      toggleSectionExpanded(false)
]
