@Newstime = @Newstime || {}

class @Newstime.TextAreaView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view text-area-view'

    @page = options.page
    @composer = options.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # Listen for model changes
    @model.bind 'change', @modelChanged, this
    @model.bind 'destroy', @modelDestroyed, this

    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup
    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'dblclick',  @dblclick
    @bind 'keydown',   @keydown
    @bind 'paste',     @paste

    @$el.css _.pick @model.attributes, 'top', 'left', 'width', 'height'

    @setContentEl(options.contentEl) if options.contentEl

    @propertiesView = new Newstime.TextAreaPropertiesView(target: this)

  setContentEl: (contentEl) ->
    @$contentEl = $(contentEl)

  modelChanged: ->
    @$el.css _.pick @model.changedAttributes(), 'top', 'left', 'width', 'height'

    if @$contentEl?
      @$contentEl.css _.pick @model.changedAttributes(), 'top', 'left', 'width', 'height'

  modelDestroyed: ->
    # TODO: Need to properly unbind events and allow destruction of view
    @$el.remove()

    @$headlineEl.remove() if @$headlineEl?

  getPropertiesView: ->
    @propertiesView

  activate: ->
    @active = true
    @trigger 'activate', this
    @$el.addClass 'resizable'

  deactivate: ->
    @active = false
    @clearEditMode()
    @trigger 'deactivate', this
    @$el.removeClass 'resizable'

  # Detects a hit of the selection
  hit: (x, y) ->

    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height

  beginSelection: (x, y) ->
    # Snap x to grid
    x = @page.snapLeft(x)

    @model.set
      left: x
      top: y

    @activate()
    @trackResize("bottom-right") # Begin tracking for size

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

  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  paste: (e) =>
    # Retreive pasted text. Not cross browser compliant. (Webkit)
    pastedText = e.originalEvent.clipboardData.getData('text/plain')

    @model.set('text', pastedText)

    # Now that we have the desired text, need to save this as the text with the
    # story text-content item, should that be our target. Also need to grab and
    # rerender the contents of the pasted text after it has been reflowed.

  keydown: (e) =>
    if @editMode


      switch e.keyCode
        when 8 # del
          e.stopPropagation()
          e.preventDefault()
          @model.backspace()
        when 27 # ESC
          e.stopPropagation()
          e.preventDefault()
          @clearEditMode()
        when 37 # left arrow
          @moveCursorLeft()
          e.stopPropagation()
          e.preventDefault()
        when 39 # right arrow
          @moveCursorRight()
          e.stopPropagation()
          e.preventDefault()
        else
          unless e.ctrlKey || e.altKey # Skip ctrl and alt
            char = @getEventChar(e)
            if char?
              console.log 'got it'
              e.stopPropagation()
              e.preventDefault()
              @model.typeCharacter(char)

    else
      switch e.keyCode
        when 8 # del
          if confirm "Are you sure you wish to delete this headline?"
            @delete()
            e.stopPropagation()
            e.preventDefault()
        when 37 # left arrow
          @stepLeft()
          e.stopPropagation()
          e.preventDefault()
        when 38 # up arrow
          # TODO: Should handle acceleration
          offset = if e.shiftKey then 20 else 1
          @model.set top: @model.get('top') - offset
          e.stopPropagation()
          e.preventDefault()
        when 39 # right arrow
          @stepRight()
          e.stopPropagation()
          e.preventDefault()
        when 40 # down arrow
          offset = if e.shiftKey then 20 else 1
          @model.set top: @model.get('top') + offset
          e.stopPropagation()
          e.preventDefault()
        when 13 # Enter
          @startEditMode()
        when 27 # ESC
          @deactivate()
        when 187 # +
          @increaseFont()
        when 189 # -
          @decreaseFont()

  increaseFont: ->
    if @model.get('font_size')
      @model.set('font_size', parseInt(@model.get('font_size')) + 1 + "px")
    else
      @model.set('font_size', @$headlineEl.css('font-size'))


  decreaseFont: ->
    if @model.get('font_size')
      @model.set('font_size', parseInt(@model.get('font_size')) - 1 + "px")
    else
      @model.set('font_size', @$headlineEl.css('font-size'))

  moveCursorLeft: ->
    if @model.get('cursorPosition')?
      @model.set('cursorPosition', Math.max(@model.get('cursorPosition') - 1, 0))
    else
      @model.set('cursorPosition', @model.get('text').length - 1)


  moveCursorRight: ->
    if @model.get('cursorPosition')?
      @model.set('cursorPosition', Math.min(@model.get('cursorPosition')+1, @model.get('text').length))
    else
      @model.get('cursorPosition', @model.get('text').length)


  getEventChar: (e) ->
    if e.shiftKey
      Newstime.shiftCharKeycodes[e.keyCode]
    else
      Newstime.charKeycodes[e.keyCode]

    #char = String.fromCharCode(e.keyCode)
      #char
    #else
      #char.toLowerCase()


  stepLeft: ->
    @model.set left: @page.stepLeft(@model.get('left'))

  stepRight: ->
    @model.set left: @page.stepRight(@model.get('left'))

  delete: ->
    @model.destroy()

  dblclick: ->
    @startEditMode()

  startEditMode: ->
    @$el.addClass 'edit-mode'
    @editMode = true

  clearEditMode: ->
    @$el.removeClass 'edit-mode'
    @editMode = false

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    x = e.x
    y = e.y

    unless @active
      @activate()

    geometry = @getGeometry()

    # If active, check against the drag handles
    # TODO: Drag handels need to become a hovered target, then if there is
    # hovered object, we can delegate down, or handle locally by entering a
    # move.
    if @active

      width   = geometry.width
      height  = geometry.height
      top     = geometry.top
      left    = geometry.left

      right   = left + width
      bottom  = top + height
      centerX = left + width/2
      centerY = top + height/2

      if @hitBox x, y, centerX, top, 8
        @trackResize "top"
        return false # Cancel event

      # right drag handle hit?
      if @hitBox x, y, right, centerY, 8
        @trackResize "right"
        return false # Cancel event

      # left drag handle hit?
      if @hitBox x, y, left, centerY, 8
        @trackResize "left"
        return false # Cancel event

      # bottom drag handle hit?
      if @hitBox x, y, centerX, bottom, 8
        @trackResize "bottom"
        return false # Cancel event

      # top-left drag handle hit?
      if @hitBox x, y, left, top, 8
        @trackResize "top-left"
        return false # Cancel event

      # top-right drag handle hit?
      if @hitBox x, y, right, top, 8
        @trackResize "top-right"
        return false # Cancel event

      # bottom-left drag handle hit?
      if @hitBox x, y, left, bottom, 8
        @trackResize "bottom-left"
        return false # Cancel event

      # bottom-right drag handle hit?
      if @hitBox x, y, right, bottom, 8
        @trackResize "bottom-right"
        return false # Cancel event

      ## Expand the geometry by buffer distance in each direction to extend
      ## clickable area.
      buffer = 4 # 2px
      geometry.left -= buffer
      geometry.top -= buffer
      geometry.width += buffer*2
      geometry.height += buffer*2

      ## Detect if corrds lie within the geometry
      if geometry.left <= x <= geometry.left + geometry.width &&
        geometry.top <= y <= geometry.top + geometry.height
          @trackMove(x - geometry.left, y - geometry.top)
          return false

    return true

  trackResize: (mode) ->
    @resizing   = true
    @resizeMode = mode

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @page.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @page.computeBottomSnapPoints()

    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @page.computeTopSnapPoints()
    @moving      = true
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this

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

  # Moves based on corrdinates and starting offset
  move: (x, y) ->
    geometry = @getGeometry()

    # Adjust x corrdinate
    x -= @moveOffsetX
    x = Math.min(x, @page.getWidth() - @model.get('width')) # Keep on page
    x = @page.snapLeft(x) # Snap

    y = @page.snapTop(y - @moveOffsetY)
    @model.set
      left: x
      top: y

  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @page.snapTop(y)
    @model.set
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    geometry = @getGeometry()
    width = x - geometry.left
    width = Math.min(width, @page.getWidth() - @model.get('left')) # Keep on page
    width = @page.snapRight(width) # Snap

    @model.set
      width: width

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    @model.set
      height: @page.snapBottom(y) - geometry.top

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @page.snapLeft(x)
    @model.set
      left: x
      width: geometry.left - x + geometry.width

  dragTopLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @page.snapLeft(x)
    y        = @page.snapTop(y)
    @model.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    y = @page.snapTop(y)
    @model.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    geometry = @getGeometry()
    x = @page.snapLeft(x)
    y = @page.snapBottom(y)
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: y - geometry.top

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    y = @page.snapBottom(y)
    @model.set
      width: width
      height: y - geometry.top

  mouseup: (e) ->
    @resizing = false
    @moving = false
    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    @$el.addClass 'hovered'
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->
    @hovered = false
    @$el.removeClass 'hovered'
    @composer.popCursor()

  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom