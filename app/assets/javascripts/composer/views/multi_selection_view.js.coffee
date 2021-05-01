class @Newstime.MultiSelectionView extends @Newstime.View

  initialize: (options={}) ->
    @$el.addClass 'selection-view resizable'

    @composer = options.composer || Newstime.composer

    @selectedViews = []
    @page = null

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    @bindUIEvents()

  render: ->
    position = @getPosition()

    ## Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)

  # Creates a group from the multi-selection.
  createGroup: ->
    {canvas} = @composer

    # Create a new GroupView
    groupView = @composer.groupViewCollection.add({})

    # Put views to be grouped in proper stacking order based on page->z-index
    sorted = @selectedViews.sort (a, b) ->
      if a.pageView.model.get('number') != b.pageView.model.get('number')
        a.pageView.model.get('number') - b.pageView.model.get('number')
      else if a.model.get('z_index') != b.model.get('z_index')
        a.model.get('z_index') - b.model.get('z_index')

    # Get the index to insert the group at from first item
    index = _.first(sorted).model.get('z_index')

    # Remove all of the view to be group, keep in order
    # Push views into group according to order
    #sorted = sorted.reverse() # Bottom to top
    _.each sorted.reverse(), (view) ->
      canvas.removeCanvasItem(view)
      groupView.addCanvasItem(view)

    # Add group to canvas
    #canvas.insertAt(index, groupView)
    canvas.addCanvasItem(groupView)

    # Select group
    @composer.select(groupView)

  addView: (view) ->
    @selectedViews.push(view)
    view.addClass 'multi-selected'
    # Can only group if has more than one selected views.
    @canGroup = @selectedViews.length > 1
    # @listenTo view.model, 'change', @render # This line was causein moving a multi select to act really weird.
    @render()

  removeView: (view) ->
    index = @selectedViews.indexOf(view)
    @selectedViews.splice(index, 1)
    view.removeClass 'multi-selected'
    @canGroup = @selectedViews.length > 1
    @stopListening view.model
    @render()

  getPropertiesView: ->
    null # TODO: Create a propeties panel view

  keydown: (e) ->
    switch e.keyCode
      when 8 # del
        if confirm "Are you sure you wish to delete these items?"
          @delete()
        e.stopPropagation()
        e.preventDefault()
      when 71 # g
        @createGroup() if e.altKey

      when 27 # ESC
        @composer.clearSelection()

  delete: ->
    _.each @selectedViews, (view) ->
      view.delete()
    @destroy()

  destroy: ->
    @remove()

  remove: ->
    unless @destroyed
      @destroyed = true
      @trigger 'destroy', this

      _.each @selectedViews, (view) ->
        view.deselect()
        view.removeClass 'multi-selected'

    super

  trackMove: (offsetX, offsetY) ->
    #@pageView.computeTopSnapPoints()
    #@pageView.collectLeftEdges(@model)
    #@pageView.collectRightEdges(@model)
    @moving      = true

    position = @getPosition()
    @orginalPositionX = position.left
    @orginalPositionY = position.top
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this

  class MouseEvents
    mousedown: (e) ->
      return unless e.button == 0 # Only respond to left button mousedown.

      if @hoveredHandle
        @trackResize @hoveredHandle.type
      else
        position = @getPosition()
        @trackMove(e.x - position.left, e.y - position.top)

         #OK, so just a note, but looks like moveing an object is actually a
         #feature of the canvas view layer, which should on each move, figure out
         #which to query into to check against snap points, and infact, can do
         #this against multi pages, and even other objects, and will also need to
         #do similar for highlighting snap points.

    mouseup: (e) ->
      if @resizing
        @resizing = false
        @resizeMode = null

        @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
        # Reset drag handles, clearing if they where active
        _.each @dragHandles, (h) -> h.reset()
        @canvasItemView.trigger 'resized'

      if @moving
        @moving = false
        @composer.clearVerticalSnapLines()

        _.each @selectedViews, (view) =>
          @composer.assignPage(view.model, view)

      @trigger 'tracking-release', this


    mouseover: (e) ->
      @hovered = true
      @composer.pushCursor @getCursor()

    mouseout: (e) ->
      @hovered = false
      @composer.popCursor()

    mousemove: (e) ->
      #@adjustEventXY(e)
      if @resizing
        switch @resizeMode
          when 'top'          then @dragTop(e.x, e.y)
          when 'right'        then @dragRight(e.x, e.y)
          when 'bottom'       then @dragBottom(e.x, e.y)
          when 'left'         then @dragLeft(e.x, e.y)
          when 'top-left'     then @dragTopLeft(e.x, e.y)
          when 'top-right'    then @dragTopRight(e.x, e.y)
          when 'bottom-left'  then @dragBottomLeft(e.x, e.y)
          when 'bottom-right' then @dragBottomRight(e.x, e.y)

      else if @moving
        @move(e.x, e.y, e.shiftKey)

  class TouchEvents

    # `touchstart` is a touch event triggered by the
    # browser

    touchstart: (e) ->
      touch = e.touches[0]
      x = touch.x
      y = touch.y

      # Time when the touch began
      # @touchT = Date.now()

      hitHandle = @hitsDragHandle(x, y)

      if hitHandle
        @trackResize hitHandle
      else
        geometry = @getPosition()
        @trackMove(x - geometry.left, y - geometry.top)
        # @moved = false # Flag set to see if moved, useful in determining tap

    touchmove: (e) ->
      touch = e.touches[0]
      x = touch.x
      y = touch.y

      if @group
        {top, left} = @group.attributes
        x -= left
        y -= top

      if @resizing

        switch @resizeMode
          when 'top'          then @dragTop(x, y)
          when 'right'        then @dragRight(x, y)
          when 'bottom'       then @dragBottom(x, y)
          when 'left'         then @dragLeft(x, y)
          when 'top-left'     then @dragTopLeft(x, y)
          when 'top-right'    then @dragTopRight(x, y)
          when 'bottom-left'  then @dragBottomLeft(x, y)
          when 'bottom-right' then @dragBottomRight(x, y)
      else if @moving
        # @moved = true
        @move(x, y)

    touchend: (e) ->
      if @resizing
        @resizing = false
        @resizeMode = null

        @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
        # Reset drag handles, clearing if they where active
        _.each @dragHandles, (h) -> h.reset()
        # @contentItemView.trigger 'resized'

      if @moving
        @moving = false
        # if @moved
        @composer.clearVerticalSnapLines()
        # @composer.assignPage(@contentItem, @contentItemView)
        # @contentItemView.trigger 'moved'

      @trigger 'tracking-release', this


    tap: (e) ->
      # {x, y} = e.center
      {pageX: x, pageY: y} = e.pointers[0]

      selection = null

      selection = _.find @selectedViews, (view) ->
        view.hit(x, y, buffer: 24)

      if selection
        selection.trigger 'tap', e

    doubletap: (e) ->
      @composer.clearSelection()


  if MOBILE?
    @include TouchEvents
  else
    @include MouseEvents

  hitsDragHandle: (x, y) ->
    geometry = @getPosition()

    # TODO: This should all be precalulated
    width   = geometry.width
    height  = geometry.height
    top     = geometry.top
    left    = geometry.left

    if @group
      top  += @group.get('top')
      left += @group.get('left')

    right   = left + width
    bottom  = top + height
    centerX = left + width/2
    centerY = top + height/2

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
    console.log x, y, left, top, boxSize
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

  getBounds: ->
    bounds = _.clone(@getPosition())
    bounds.bottom = bounds.top + bounds.height
    bounds.right = bounds.left + bounds.width
    delete bounds.width
    delete bounds.height
    bounds

  getCursor: ->
    'default'

  getPosition: ->
    @calculatePosition()
    @position

  calculatePosition: =>
    models = _.pluck @selectedViews, 'model'

    top = models[0].get('top')
    left = models[0].get('left')
    bottom = 0
    right = 0

    _.each models, (model) =>
      # TODO: Need to take into consideration page position
      page = model.getPage() # Need to have access to page offsets at the model
      if page
        pageOffsetTop  = page.get('offset_top') || 0
        pageOffsetLeft = page.get('offset_left') || 0

        top    = Math.min(model.get('top') + pageOffsetTop, top)
        left   = Math.min(model.get('left') + pageOffsetLeft, left)
        bottom = Math.max(model.get('top') + model.get('height') + pageOffsetTop, bottom)
        right  = Math.max(model.get('left') + model.get('width') + pageOffsetLeft, right)

    @position =
      top: top
      left: left
      height: bottom - top
      width: right - left

    # TODO: Use top, left, bottom, right for bounding boxes.
    # Create Bounding box class.

    # And expended position bounding box used for hit detection.
    @expandedPosition = @addBuffer(@position, 4)

  # Detects a hit of the selection
  hit: (x, y) ->
    # @hitsBoundingBox(@expandedPosition, x, y)

    # selection = null

    # Match against children to allow tapping views within the bounding box.
    !!_.find @selectedViews, (view) ->
      view.hit(x, y, buffer: 24)

  # Expand the bounding box by buffer distance in each direction to extend
  # clickable area.
  addBuffer: (box, buffer) ->
    box = _.clone(box)

    box.top -= buffer
    box.left -= buffer
    box.width += buffer*2
    box.height += buffer*2

    box

  hitsBoundingBox: (box, x, y) ->
    ## Detect if corrds lie within the geometry
    box.left <= x <= box.left + box.width &&
      box.top <= y <= box.top + box.height

  setSizeAndPosition: (value) ->
    models = _.pluck @selectedViews, 'model'

    _.each models, (model) =>
      topOffset = model.get('top') - @position.top
      leftOffset = model.get('left') - @position.left

      model.set
        top: value.top + topOffset
        left: value.left + leftOffset
    @calculatePosition()
    @render()

  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom
