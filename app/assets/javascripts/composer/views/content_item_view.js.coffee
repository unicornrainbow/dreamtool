#= require ../views/canvas_item_view

class @Newstime.ContentItemView extends @Newstime.CanvasItemView

  className: 'content-item-view'

  initializeCanvasItem: ->
    @initializeContentItem()

  addClassNames: ->
    @$el.addClass "#{@className} #{@contentItemClassName}"

  # Does a full server render and replaces dom element.
  serverRender: ->
    $.ajax
      method: 'GET'
      url: "#{@edition.url()}/render_content_item.html"
      data:
        composing: true
        content_item: @model.toJSON()
      success: (response) =>
        # Parse response into element.
        el = @_parseHTML(response)

        # Attach and render
        @$el.replaceWith(el)
        @setElement(el)
        @render()
        @trigger 'set-element'

  handelChangePage: ->
    @page = @model.getPage()
    @pageView = @composer.pageViews[@page.cid]

  select: (selectionView) ->
    unless @selected
      @selected = true
      @selectionView = selectionView
      @trigger 'select',
        contentItemView: this
        contentItem: @model

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this

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
    #parseInt(@$el.css('height'))

  getEventChar: (e) ->
    if e.shiftKey
      Newstime.shiftCharKeycodes[e.keyCode]
    else
      Newstime.charKeycodes[e.keyCode]

  stepLeft: ->
    @model.set left: @pageView.stepLeft(@model.get('left'))

  stepRight: ->
    @model.set left: @pageView.stepRight(@model.get('left'))

  class MouseEvents
    mousedown: (e) ->
      return unless e.button == 0 # Only respond to left button mousedown.

      if @selected
        if e.shiftKey
          # Remove from selection
          @composer.removeFromSelection(this)
      else
        if e.shiftKey
          # Add to selection
          @composer.addToSelection(this)
        else
          @composer.select(this) # TODO: Shift+click with add to selection. alt-click will remove from.

      # Pass mouse down to selection
      @composer.activeSelectionView.trigger 'mousedown', e

      #if @hoveredHandle
        #@trackResize @hoveredHandle.type
      #else
        #geometry = @getGeometry()
        #@trackMove(e.x - geometry.left, e.y - geometry.top)
        #

    mouseup: (e) ->
      #TODO: Need to remove this code, which is no longer used do to selection
      #view

      if @resizing
        @resizing = false
        @resizeMode = null

        @composer.hideVerticalSnapLine() # Ensure vertical snaps aren't showing.
        # Reset drag handles, clearing if they where active
        _.each @dragHandles, (h) -> h.reset()
        @trigger 'resized'

      if @moving?
        @moving = false

      @trigger 'tracking-release', this

    mousemove: (e) ->
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
        @move(e.x, e.y)

      else if @active
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
      #@$el.addClass 'hovered'
      @outlineView.show()
      @composer.pushCursor @getCursor()


    mouseout: (e) ->

      if @hoveredHandle
        @hoveredHandle.trigger 'mouseout', e
        @hoveredHandle = null

      @hovered = false
      #@$el.removeClass 'hovered'
      @outlineView.hide()
      @composer.popCursor()


  if MOBILE?
    # @include TouchEvents
  else
    @include MouseEvents

  trackResize: (mode) ->
    @resizing   = true
    @resizeMode = mode

    # Highlight the drag handle
    _.find(@dragHandles, (h) -> h.type == mode).selected()

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @pageView.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @pageView.computeBottomSnapPoints()

    switch @resizeMode
      when 'left', 'top-left', 'bottom-left'
        @pageView.collectLeftEdges(@model)

      #when 'right', 'top-right', 'bottom-right'
        #@pageView.collectRightEdges(this)


    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @pageView.computeTopSnapPoints()
    @moving      = true
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this


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

    boxSize = 18

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


  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom


  # Parses html in to dom element.
  _parseHTML: (html) ->
    div = document.createElement('div')
    div.innerHTML = html
    div.firstChild
