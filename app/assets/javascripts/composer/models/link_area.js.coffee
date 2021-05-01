class @Newstime.LinkArea
  _.extend @prototype, Backbone.Events

  constructor: (link, options={}) ->
    @$link = $(link)
    @topOffset = options.topOffset || 0
    @composer = options.composer

    @bind
      mousedown: @mousedown
      mouseover: @mouseover
      mouseout:  @mouseout


  # Detects a hit of the selection
  hit: (x, y) ->
    ## Detect if corrds lie within the geometry
    @left <= x <= @left + @width &&
      @top <= y <= @top + @height

  mousedown: (e) ->
    window.location = @$link.attr('href')

  mouseover: (e) ->
    @$link.addClass 'hover'
    @composer.pushCursor('pointer')

  mouseout: (e) ->
    @$link.removeClass 'hover'
    @composer.popCursor()

  measure: (canvasPosition) ->
    # Get area
    @position = @$link.offset()
    @top = @position.top - @topOffset
    @left = @position.left - canvasPosition.left
    @width = @$link.width()
    @height = @$link.height()
    @trigger 'change'
