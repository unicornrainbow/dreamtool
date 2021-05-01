class @Newstime.MastheadSelectionView extends @Newstime.View

  initialize: (options) ->
    @$el.addClass 'selection-view resizable'

    @composer = options.composer || Newstime.composer

    # Add drag handles
    @dragHandles = ['bottom']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # HACK: Shouldn't be binding direct to the content item model and view
    @mastheadView = options.mastheadView
    @model = @mastheadView.model

    @page = @mastheadView.page
    @pageView = @mastheadView.pageView

    @listenTo @model ,'change', @render
    @listenTo @mastheadView, 'deselect', @remove

    @bindUIEvents()

  getPropertiesView: ->
    @mastheadView.getPropertiesView()

  remove: ->
    unless @destroyed
      @destroyed = true
      @trigger 'destroy', this

      if @mastheadView
        @mastheadView.deselect()

    super


  render: ->
    position = _.pick @model.attributes, 'width', 'height'

    position.top  = @model.get('top')
    position.left = @model.get('left')

    # Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)


    _.each @dragHandles, (handle) =>
      handle.$el.toggle(!@model.get('lock'))

    this

  paste: (e) ->
    @mastheadView.trigger 'paste', e

  getLeft: ->
    @model.get('left')
    #parseInt(@$el.css('left'))

  getTop: ->
    @model.get('top')
    #parseInt(@$el.css('top'))

  getWidth: ->
    @model.get('width')
    #parseInt(@$el.css('width'))

  getHeight: ->
    @model.get('height')

  keydown: (e) ->
    @mastheadView.trigger 'keydown', e

  dblclick: (e) ->
    @mastheadView.trigger 'dblclick', e

  # Detects a hit of the selection
  hit: (x, y) ->
    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 8 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height


  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  getBounds: ->
    bounds = @model.pick('top', 'left', 'height', 'width')
    bounds.bottom = bounds.top + bounds.height
    bounds.right = bounds.left + bounds.width
    delete bounds.width
    delete bounds.height
    bounds


  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    if @hoveredHandle
      @trackResize @hoveredHandle.type

  trackResize: (mode) ->
    @resizing   = true
    @mastheadView.needsReflow = true # TODO: Should use resize event
    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles, (h) -> h.type == mode).selected()

    #switch @resizeMode
      #when 'bottom'
        #@pageView.computeBottomSnapPoints()

        ## Get all objects below object that can be moved up and down in unison.
        #@attachedItems = @pageView.getAttachedItems(@model)


    @trigger 'tracking', this

  mousemove: (e) ->
    if @resizing
      switch @resizeMode
        when 'bottom'       then @dragBottom(e.x, e.y)

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


  hitsDragHandle: (x, y) ->
    geometry = @getGeometry()

    # TODO: This should all be precalulated
    width   = geometry.width
    height  = geometry.height
    top     = geometry.top
    left    = geometry.left

    right   = left + width
    bottom  = top + height
    centerX = left + width/2
    centerY = top + height/2

    boxSize = 8

    if @composer.zoomLevel
      # Compensate box size for zoom level
      boxSize /= @composer.zoomLevel

    # bottom drag handle hit?
    if @hitBox x, y, centerX, bottom, boxSize
      return "bottom"

  dragBottom: (x, y) ->
    @mastheadView.dragBottom(x, y)

    _.each @attachedItems, ([contentItem, offset]) =>
      contentItem.set
        top: y + offset.offsetTop

  mouseup: (e) ->
    if @resizing
      @resizing = false
      @resizeMode = null

      @composer.clearVerticalSnapLines() # Ensure vertical snaps aren't showing.
      # Reset drag handles, clearing if they where active
      _.each @dragHandles, (h) -> h.reset()
      @mastheadView.trigger 'resized'

    if @moving
      @moving = false
      @composer.clearVerticalSnapLines()
      @composer.assignPage(@model, @mastheadView)

    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->

    if @hoveredHandle
      @hoveredHandle.trigger 'mouseout', e
      @hoveredHandle = null

    @hovered = false
    #@$el.removeClass 'hovered'
    @composer.popCursor()


  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom
