

class @Newstime.SelectionView extends Newstime.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'

    @composer = options.composer || Newstime.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # HACK: Shouldn't be binding direct to the content item model and view
    @contentItemView = options.contentItemView
    @contentItem = @contentItemView.model

    unless @contentItemView.groupView
      @page = @contentItemView.page
      @pageView = @contentItemView.pageView
    else
      @groupView = @contentItemView.groupView
      @page = @groupView.page
      @pageView = @groupView.pageView


    @listenTo @contentItem ,'change', @render
    @listenTo @contentItemView, 'deselect', @remove

    @bindUIEvents()

    @group = @contentItem.getGroup()

  render: ->
    position = @contentItemView.getGeometry()


    # console.log 'g', @group
    if @group
      # position.top  += @group.get('top')
      # position.left += @group.get('left')
      position.top += @group.getOffsetTop()
      position.left += @group.getOffsetLeft()


    # Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)

    this

  ## Event handlers ##
  class MouseEvents

    mousedown: (e) ->
      return unless e.button == 0 # Only respond to left button mousedown.

      if @hoveredHandle
        @trackResize @hoveredHandle.type
      else
        geometry = @getGeometry()
        @trackMove(e.x - geometry.left, e.y - geometry.top)

    mouseup: (e) ->
      if @resizing
        @resizing = false
        @resizeMode = null

        @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
        # Reset drag handles, clearing if they where active
        _.each @dragHandles, (h) -> h.reset()
        @contentItemView.trigger 'resized'

      if @moving
        @moving = false
        @composer.clearVerticalSnapLines()
        @composer.assignPage(@contentItem, @contentItemView)

      @trigger 'tracking-release', this

    mousemove: (e) ->
      if @resizing
        {x, y} = e
        c = @contentItemView
        g = c.getGeometry()

        switch @resizeMode
          when 'top'
            if y > g.top + g.height
              @switchResizeMode 'bottom'
            else
              @dragTop(x, y)
          when 'right'
            if x < g.left
              @switchResizeMode 'left'
            else
             @dragRight(x, y)
          when 'bottom'
            if y < g.top
              @switchResizeMode 'top'
            else
              @dragBottom(x, y)
          when 'left'
            if x > g.left + g.width
              @switchResizeMode 'right'
            else
              @dragLeft(x, y)
          when 'top-left'
            if x > g.left + g.width
              if y > g.top + g.height
                @switchResizeMode('bottom-right')
              else
                @switchResizeMode('top-right')
            else
              if y > g.top + g.height
                @switchResizeMode('bottom-left')
              else
                @dragTopLeft(x, y)
          when 'top-right'
            if x < g.left
              if y > g.top + g.height #bottom
                @switchResizeMode('bottom-left')
              else
                @switchResizeMode('top-left')
            else
              if y > g.top + g.height
                @switchResizeMode('bottom-right')
              else
                @dragTopRight(x, y)
          when 'bottom-left'
            if x > g.left + g.width
              if y < g.top
                @switchResizeMode('top-right')
              else
                # @swremo 'bottom-right'
                @switchResizeMode('bottom-right')
            else
              if y < g.top
                @switchResizeMode('top-left')
              else
                @dragBottomLeft(x, y)
          when 'bottom-right'
            if x < @contentItemView.model.get('left')
              if y < @contentItemView.model.get('top')
                @switchResizeMode('top-left')
                @dragTopLeft(x, y)
              else
                @switchResizeMode('bottom-left')
                @dragBottomLeft(x, y)
            else
              if y < @contentItemView.model.get('top')
                @switchResizeMode('top-right')
              else
                @dragBottomRight(x, y)

      else if @moving
        @move(e.x, e.y, e.shiftKey)
      else
        # Check for hit handles
        hit = @hitsDragHandle(e.x, e.y)
        hit = _.find(@dragHandles, (h) -> h.type == hit)
        if @hoveredHandle && hit
          if @hoveredHandle != hit
            @hoveredHandle.trigger 'mouseout', e
            @hoveredHandle = hit
            @hoveredHandle.trigger 'mouseover', e
        else if @hoveredHandle
          @hoveredHandle.trigger 'mouseout', e
          @hoveredHandle = null

        else if hit
          @hoveredHandle = hit
          @hoveredHandle.trigger 'mouseover', e

    mouseover: (e) ->
      @hovered = true
      @composer.pushCursor @getCursor()

    mouseout: (e) ->

      if @hoveredHandle
        @hoveredHandle.trigger 'mouseout', e
        @hoveredHandle = null

      @hovered = false
      #@$el.removeClass 'hovered'
      @composer.popCursor()

    dblclick: (e) ->
      @contentItemView.trigger 'dblclick', e

  class TouchEvents

    # `touchstart` is a touch event triggered by the
    # browser

    touchstart: (e) ->
      touch = e.touches[0]
      x = touch.x
      y = touch.y

      # Time when the touch began
      # @touchT = Date.now()

      if @group
        # x  -= @group.get('left')
        # y  -= @group.get('top')
        x -= @group.getOffsetLeft()
        y -= @group.getOffsetTop()


      hitHandle = @hitsDragHandle(x, y)
      # console.log 'hh', hitHandle

      if hitHandle
        @trackResize hitHandle
      else
        geometry = @getGeometry()
        @trackMove(x - geometry.left, y - geometry.top)
        # @moved = false # Flag set to see if moved, useful in determining tap

    touchmove: (e) ->
      touch = e.touches[0]
      x = touch.x
      y = touch.y

      if @group
        # x  -= @group.get('left')
        # y  -= @group.get('top')
        x -= @group.getOffsetLeft()
        y -= @group.getOffsetTop()

      if @resizing
        c = @contentItemView
        g = c.getGeometry()

        switch @resizeMode
          when 'top'
            if y > g.top + g.height
              @switchResizeMode 'bottom'
            else
              @dragTop(x, y)
          when 'right'
            if x < g.left
              @switchResizeMode 'left'
            else
             @dragRight(x, y)
          when 'bottom'
            if y < g.top
              @switchResizeMode 'top'
            else
              @dragBottom(x, y)
          when 'left'
            if x > g.left + g.width
              @switchResizeMode 'right'
            else
              @dragLeft(x, y)
          when 'top-left'
            if x > g.left + g.width
              if y > g.top + g.height
                @switchResizeMode('bottom-right')
              else
                @switchResizeMode('top-right')
            else
              if y > g.top + g.height
                @switchResizeMode('bottom-left')
              else
                @dragTopLeft(x, y)
          when 'top-right'
            if x < g.left
              if y > g.top + g.height #bottom
                @switchResizeMode('bottom-left')
              else
                @switchResizeMode('top-left')
            else
              if y > g.top + g.height
                @switchResizeMode('bottom-right')
              else
                @dragTopRight(x, y)
          when 'bottom-left'
            if x > g.left + g.width
              if y < g.top
                @switchResizeMode('top-right')
              else
                # @swremo 'bottom-right'
                @switchResizeMode('bottom-right')
            else
              if y < g.top
                @switchResizeMode('top-left')
              else
                @dragBottomLeft(x, y)
          when 'bottom-right'
            if x < @contentItemView.model.get('left')
              if y < @contentItemView.model.get('top')
                @switchResizeMode('top-left')
                @dragTopLeft(x, y)
              else
                @switchResizeMode('bottom-left')
                @dragBottomLeft(x, y)
            else
              if y < @contentItemView.model.get('top')
                @switchResizeMode('top-right')
              else
                @dragBottomRight(x, y)
      else if @moving
        # @moved = true
        @move(x, y)
        @motorboat(x, y)


    touchend: (e) ->
      if @resizing
        @resizing = false
        @resizeMode = null

        @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
        # Reset drag handles, clearing if they where active
        _.each @dragHandles, (h) -> h.reset()
        @contentItemView.trigger 'resized'

      if @moving
        @moving = false
        # if @moved
        @composer.clearVerticalSnapLines()
        @composer.assignPage(@contentItem, @contentItemView)
        @contentItemView.trigger 'moved'

      @trigger 'tracking-release', this

    tap: (e) ->
      @contentItemView.trigger 'tap', e

    doubletap: (e) ->
      @contentItemView.trigger 'doubletap', e

    press: (e) ->
      @contentItemView.trigger 'press', e


  if MOBILE?
    @include TouchEvents
  else
    @include MouseEvents

  motorboat: (x, y) ->
    windowHeight = Math.round($(window).height())
    scrollTop = Math.round($(window).scrollTop())
    bottom = @contentItem.get('top') + @contentItem.get('height') + 60
    top = @contentItem.get('top') # + 60
    height = @contentItem.get('height')

    if @group
      y += @group.getOffsetTop()

    topDistance   =  y - scrollTop
    bottomDistance = windowHeight - (y - scrollTop)

    if topDistance < 120
      $(window).scrollTop(scrollTop - (120 - topDistance)/3)

    if bottomDistance < 190
      $(window).scrollTop(scrollTop + (190 - bottomDistance)/3)


  paste: (e) ->
    @contentItemView.trigger 'paste', e

  keydown: (e) ->
    @contentItemView.trigger 'keydown', e

  ####

  getPropertiesView: ->
    @contentItemView.getPropertiesView()

  remove: ->
    unless @destroyed
      @destroyed = true
      @trigger 'destroy', this

      if @contentItemView
        @contentItemView.deselect()
        @contentItemView.removeClass 'multi-selected'

    super


  getLeft: ->
    @contentItem.get('left')
    #parseInt(@$el.css('left'))

  getTop: ->
    @contentItem.get('top')
    #parseInt(@$el.css('top'))

  getWidth: ->
    @contentItem.get('width')
    #parseInt(@$el.css('width'))

  getHeight: ->
    @contentItem.get('height')

  getGeometry: ->
    @contentItem.pick('top', 'left', 'height', 'width')

  getBounds: ->
    bounds = @contentItem.pick('top', 'left', 'height', 'width')
    bounds.bottom = bounds.top + bounds.height
    bounds.right = bounds.left + bounds.width
    delete bounds.width
    delete bounds.height
    bounds

  beginDraw: (x, y) ->
    # TODO: Rewrite this with selection
    # Snap x to grid
    @pageView.collectLeftEdges(@contentItem)
    snapX = @pageView.snapLeft(x)
    if snapX
      x = snapX

    @contentItem.set
      left: x
      top: y
      width: 1 # HACK: Set some initial value for width and height to avoid it not being set.
      height: 1

    @trackResize("bottom-right") # Begin tracking for size

  trackResize: (mode) ->
    @resizing   = true
    @contentItemView.needsReflow = true # TODO: Should use resize event
    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles, (h) -> h.type == mode).selected()

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @pageView.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @pageView.computeBottomSnapPoints()

        # Get all objects below object that can be moved up and down in unison.
        @attachedItems = @pageView.getAttachedItems(@contentItem)


    switch @resizeMode
      when 'left', 'top-left', 'bottom-left'
        @pageView.collectLeftEdges(@contentItem)

      #when 'right', 'top-right', 'bottom-right'
        #@pageView.collectRightEdges(this)


    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @pageView.computeTopSnapPoints()
    @pageView.collectLeftEdges(@contentItem)
    @pageView.collectRightEdges(@contentItem)
    @moving      = true
    @orginalPositionX = @contentItem.get('left')
    @orginalPositionY = @contentItem.get('top')
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this

  switchResizeMode: (mode) ->
    # @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.

    _.find(@dragHandles,
      (h) => h.type == @resizeMode)
    .reset()

    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles,
      (h) -> h.type == mode)
    .selected()

  # Detects a hit of the selection
  hit: (x, y) ->
    geometry = @getGeometry()
    geometry = new Newstime.Boundry(geometry)

    outerBoundry = geometry.dup().expandBy(12)

    if outerBoundry.hit(x,y)
      geometry.hit(x,y) || @hitsDragHandle(x,y)



  hitsDragHandle: (x, y) ->
    geometry = @getGeometry()

    # TODO: This should all be precalulated
    width   = geometry.width
    height  = geometry.height
    top     = geometry.top
    left    = geometry.left

    right   = left + width
    bottom  = top + height
    centerX = left + width/2 + 1
    centerY = top + height/2 + 1

    boxSize = 18

    if @composer.zoomLevel
      # Compensate box size for zoom level
      boxSize /= @composer.zoomLevel

    if @hitBox x, y, centerX, top, boxSize
      return "top"

    # right drag handle hit?
    if @hitBox x, y, right, centerY, boxSize
      return "right"

    # left drag handle hit?
    if @hitBox x, y, left, centerY, boxSize
      return "left"

    # bottom drag handle hit?
    if @hitBox x, y, centerX, bottom, boxSize
      return "bottom"

    # top-left drag handle hit?
    # console.log x, y, left, top, boxSize
    if @hitBox x, y, left, top, boxSize
      return "top-left"

    # top-right drag handle hit?
    if @hitBox x, y, right, top, boxSize
      return "top-right"

    # bottom-left drag handle hit?
    if @hitBox x, y, left, bottom, boxSize
      return "bottom-left"

    # bottom-right drag handle hit?
    if @hitBox x, y, right, bottom, boxSize
      return "bottom-right"


  # Moves based on corrdinates and starting offset
  move: (x, y, shiftKey=false) ->
    x -= @moveOffsetX
    y -= @moveOffsetY

    @composer.moveItem(this, x, y, @orginalPositionX, @orginalPositionY, shiftKey)
    #@pageView.moveItem(this, x, y, @orginalPositionX, @orginalPositionY, shiftKey)

  setSizeAndPosition: (value) ->
    @contentItemView.setSizeAndPosition(value)


  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @pageView.snapTop(y)

    @contentItemView.setSizeAndPosition
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->

    if @group
      x  += @group.get('left')

    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()

    x = Math.min(x, @pageView.getWidth()) # Keep on page
    snapRight = @pageView.snapRight(x) # Snap

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width = x - geometry.left

    if @group
      width  -= @group.get('left')

    @contentItemView.setSizeAndPosition
      width: width

  dragBottom: (x, y) ->
    @contentItemView.dragBottom(x, y)

    _.each @attachedItems, ([contentItem, offset]) =>
      contentItem.set
        top: y + offset.offsetTop

  dragLeft: (x, y) ->
    if @group
      x  += @group.get('left')

    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)

    if snapLeft
      @composer.clearVerticalSnapLines()
      @composer.drawVerticalSnapLine(snapLeft)
      x = snapLeft
    else
      @composer.clearVerticalSnapLines()

    if @group
      x  -= @group.get('left')


    @contentItemView.setSizeAndPosition
      left: x
      width: geometry.left - x + geometry.width


  dragTopLeft: (x, y) ->
    if @group
      x  += @group.get('left')

    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    y        = @pageView.snapTop(y)

    snapLeft = @pageView.snapLeft(x)

    if snapLeft
      @composer.drawVerticalSnapLine(snapLeft)
      x = snapLeft

    if @group
      x  -= @group.get('left')

    @contentItem.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    if @group
      x  += @group.get('left')

    @composer.clearVerticalSnapLines()
    geometry  = @getGeometry()
    snapRight = @pageView.snapRight(x)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width     = x - geometry.left

    y = @pageView.snapTop(y)

    if @group
      width  -= @group.get('left')

    @contentItem.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    @contentItemView.dragBottomLeft(x, y)


  dragBottomRight: (x, y) ->
    @contentItemView.dragBottomRight(x, y)


  getCursor: ->
    'default'

  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom
