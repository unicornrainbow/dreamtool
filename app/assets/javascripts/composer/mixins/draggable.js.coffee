# Draggable functionality.
class @Newstime.Draggable

  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    # y = @pageView.snapTop(y)
    @model.set
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    geometry = @getGeometry()
    width = x - geometry.left
    width = Math.min(width, @pageView.getWidth() - @model.get('left')) # Keep on page
    width = @pageView.snapRight(width) # Snap

    @model.set
      width: width

  dragBottom: (x, y) ->
    geometry = @getGeometry()

    # @ensurePageView()

    @model.set
      height: @pageView.snapBottom(y) - geometry.top

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)
    if snapLeft
      @composer.showVerticalSnapLine(snapLeft + @pageView.x())
      x = snapLeft
    else
      @composer.hideVerticalSnapLine()

    @model.set
      left: x
      width: geometry.left - x + geometry.width

  dragTopLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @pageView.snapLeft(x)
    y        = @pageView.snapTop(y)

    @model.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    geometry = @getGeometry()
    width = @pageView.snapRight(x - geometry.left)
    y = @pageView.snapTop(y)
    @model.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    if @groupView
      x  += @groupView.model.get('left')

    # @ensurePageView()

    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()

    snapLeft = @pageView.snapLeft(x)

    if snapLeft
      @composer.drawVerticalSnapLine(snapLeft)
      x = snapLeft

    if @groupView
      x  -= @groupView.model.get('left')

    y = @pageView.snapBottom(y)
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: y - geometry.top


  dragBottomRight: (x, y) ->
    if @groupView
      x  += @groupView.model.get('left')

    # @ensurePageView()

    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    snapRight = @pageView.snapRight(x)
    y         = @pageView.snapBottom(y)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width     = x - geometry.left

    if @groupView
      width  -= @groupView.model.get('left')

    @model.set
      width: width
      height: y - geometry.top


  # Moves based on corrdinates and starting offset
  move: (x, y) ->
    geometry = @getGeometry()

    # Adjust x corrdinate
    x -= @moveOffsetX
    #x = Math.min(x, @pageView.getWidth() - @model.get('width')) # Keep on page
    #x = @pageView.snapLeft(x) # Snap

    y = @pageView.snapTop(y - @moveOffsetY)
    @model.set
      left: x
      top: y

  # ensurePageView: ->
  #   if !@pageView? && @groupView
  #     @pageView = @groupView.getPageView()
