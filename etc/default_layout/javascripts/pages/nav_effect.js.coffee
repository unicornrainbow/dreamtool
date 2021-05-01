# Make so each page becomes fixed when it gets to the bottom of the page

Math.easeOutCirc = (t, b, c, d) ->
  t /= d
  t--
  return c * Math.sqrt(1 - t*t) + b

scrollDrag = ($el) ->
  height    = $el.height()
  offsetTop = $el.offset().top

  update: (windowHeight, scrollTop) ->
    # Activate once the bottom edge crosses into view port.
    if scrollTop > offsetTop + height - windowHeight
      offset = scrollTop - (offsetTop + height - windowHeight)
      if offset < 1000
        $el.css(top: offset * Math.easeOutCirc(offset, 0, 1, 3600))
      else
        $el.css(top: offset - 307.5)
    else
      $el.css
        top: 0

coverScrollDrag = scrollDrag($('#cover'))
a2ScrollDrag = scrollDrag($('#A2-page'))

drag3 = scrollDrag($('#A3-page'))
drag4 = scrollDrag($('#A4'))
drag5 = scrollDrag($('#A5'))
drag6 = scrollDrag($('#A6'))
drag7 = scrollDrag($('#A7'))
drag8 = scrollDrag($('#A8'))

$mastHead = $('.masthead')
$mastHeadHeading = $('h1', $mastHead).first()
mastHeadHeight = $mastHead.height()
showingSlideinNav = false

stickyHeaders = $(".sticky-header")

stickyHeaders = _.map stickyHeaders, (el) ->
  $el = $(el)
  $offsetParent = $el.offsetParent()
  {
    $el: $el
    $offsetParent: $offsetParent
    offsetTop: $el.offset().top
    height: $el.height()
    parentOffsetTop: $offsetParent.offset().top
  }

stickyHeaders = stickyHeaders.reverse()

$(window).scroll ->
  $window      = $(window)
  scrollTop    = $window.scrollTop()
  windowHeight = $window.height()


  coverScrollDrag.update(windowHeight, scrollTop)
  a2ScrollDrag.update(windowHeight, scrollTop)

  drag3.update(windowHeight, scrollTop)
  drag4.update(windowHeight, scrollTop)
  drag5.update(windowHeight, scrollTop)
  drag6.update(windowHeight, scrollTop)
  drag7.update(windowHeight, scrollTop)
  drag8.update(windowHeight, scrollTop)


  activeHeader = null # Holds the first active header based on position.
  activeHeaderOffset = 0

  # Assumes stickyHeaders are in reverse order than they appear on the page.
  _.each stickyHeaders, (header) ->


    offsetTop = header.offsetTop
    height = header.height
    $el = header.$el
    parentDelta = header.$offsetParent.offset().top - header.parentOffsetTop

    # 49 is the height of the main header
    if scrollTop >= offsetTop - parentDelta - 48

      if activeHeader
        if activeHeaderOffset == 0
          $el.css top: 0
        else
          $el.css
            top: scrollTop - offsetTop - parentDelta + 48 + activeHeaderOffset
      else
        $el.css top: scrollTop - offsetTop - parentDelta + 48
        activeHeader = header

    else if scrollTop >= offsetTop - parentDelta - 48 - header.height
      # In the hot zone
      activeHeader = header
      activeHeaderOffset =  offsetTop - parentDelta - 48 - header.height - scrollTop
    else
      $el.css top: 0



  #For each sticky header
  #
  #



  # TODO: Treat these as filters which can be combine to create the effect of
  # spinging in and draging out.
  # something like
  #
  #   dragOut, popIn
  #
  #   $el.css(top: dragOut(popIn($el)))
  #
  #   top =
  #
