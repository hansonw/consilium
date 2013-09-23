$(document).ready ->
  $('.section').css('width', $(window).width())
  $('.section').css('height', $(window).height())

  findSectionById = (id) ->
    console.log id
    $(".navbar a[href='##{id}']")

  $('.navbar-links a').click (e) ->
    return false if !e.target?
    $('html, body').animate
      scrollTop: $("#{$(e.target).attr('href')}").offset().top
    , 500
    e.preventDefault()

  $(window).scroll ->
    scrollTop = $(window).scrollTop()

    if scrollTop > 0
      $('.navbar').addClass('active')
    else
      $('.navbar').removeClass('active')

    closestSection = undefined
    closestDist = undefined
    $('.section').each ->
      dist = Math.abs($(@).offset().top - scrollTop)
      if !closestSection? || dist < closestDist
        closestSection = @
        closestDist = dist

    $('.navbar a').removeClass('active')
    findSectionById($(closestSection).attr('id')).addClass('active')
