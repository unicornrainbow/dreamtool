#= require ../views/canvas_item_view

App = Newstime

#  A group view as an implementation of canvas item view. It represents a group
#  as it appears on, and interacts, with the canvas.
#
class @Newstime.GroupView extends @Newstime.CanvasItemView

  className: 'group-view'

  @getter 'uiLabel', -> 'Group'

  initializeCanvasItem: (options={}) ->
    @contentItemViewsArray = [] # Array of content items views in z-index order.

    @leftBorder = @model.get('left_border')
    if @leftBorder
      @$el.addClass 'group-left-border'

    @listenTo @model, 'change:height change:width', @resize
    @bind 'resized', @resized  # Reflow text on resize

  # Adds view to group.
  addCanvasItem: (view, options={}) ->
    viewBoundry = view.model.getBoundry()

    unless options.reattach

      # If this is the first view in the group
      if @contentItemViewsArray.length == 0
        # clone the boundry
        @model.set _.pick viewBoundry, 'top', 'left', 'width', 'height'

        # zero position of element
        view.model.set(top: 0, left: 0)
      else
        # Union boundry into group
        groupBoundry = @getBoundry()
        newBoundry = groupBoundry.union(viewBoundry)

        @_setBoundry(newBoundry)

        # Subtract group offset from element offset.
        view.model.set
          top: viewBoundry.top - newBoundry.top
          left: viewBoundry.left - newBoundry.left

    @contentItemViewsArray.push(view)
    # @outlineView.attach(view.outlineView)
    @$el.append(view.el)
    view.groupView = this
    view.setPageView @pageView

    @listenTo view, 'resized, moved', @contentItemAdjust
    # @listenTo view, 'moved',   @contentItemAdjust

    @model.addItem(view.model)

    if view instanceof Newstime.TextAreaView
      @model.set 'story_title', view.model.get('story_title') # HACK: Need to make sure this stays in sync and is updated...

    @getPorps()


  # In a world of groups, finds the pageView.
  getPageView: ->
    @pageView || @groupView?.getPageView()

  setPageView: (pageView) ->
    @pageView = pageView

    # Pass on the pageView to the grouped items
    _.invoke @contentItemViewsArray,
      'setPageView', pageView

  removeCanvasItem: (canvasItemView) ->

    index = @contentItemViewsArray.indexOf(canvasItemView)

    if index == -1
      throw "Couldn't find canvas item."

    @stopListening canvasItemView

    @contentItemViewsArray.splice(index, 1)
    @outlineView.remove(canvasItemView.outlineView)
    canvasItemView.groupView = null
    canvasItemView.$el.detach()

    groupBoundry = @getBoundry()

    canvasItemView.model.set
      top: groupBoundry.top + canvasItemView.model.top
      left: groupBoundry.left + canvasItemView.model.left

    # TODO: Reapply position for group view

    # Update z-indexs
    #@updateZindexs()

    canvasItemView.model.unset('group_id')
    canvasItemView.model.group = null


  resized: ->
    _.invoke @contentItemViewsArray, 'trigger', 'resized'

    # _.each @contentItemViewsArray, (contentItemView) ->
    #   if contentItemView instanceof Newstime.TextAreaView
    #     contentItemView.reflow()

  # Collects and stores porportions for each of the grouped items,
  # which are later used during group resize to distribute the resize
  # in a somewhat agreeable manner.
  getPorps: ->
    width = @model.get('width')
    height = @model.get('height')

    @porportions ?= []
    contentItems = _.pluck @contentItemViewsArray, 'model'
    i = 0
    _.each contentItems, (item) =>
      boundry = item.getBoundry()
      top = 1 - (height - boundry.top) / height
      left = 1 - (width - boundry.left) / width
      w = 1 - (width - boundry.width) / width
      h = 1 - (height - boundry.height) / height
      @porportions[i] = {top, left, width: w, height: h}
      i++

  resize: ->
    if @selectionView?.resizing
      # console.log 'resizin', @porportions
      width = @model.get('width')
      height = @model.get('height')

      contentItems = _.pluck @contentItemViewsArray, 'model'
      i = 0
      _.each contentItems, (item) =>
        boundry = item.getBoundry()
        {top, left, width: w, height: h} = @porportions[i]

        top = height * top
        left = width * left
        w = width * w
        h = height * h
        item.set {top, left, width: w, height: h}
        i++

  contentItemAdjust: ->
    {top: topOffset, left: leftOffset} = @getBoundry()

    @contentItems = _.pluck @contentItemViewsArray, 'model'
    first = _.first(@contentItems)
    if first?
      boundry =  first.getBoundry()


      top = boundry.top
      left = boundry.left
      bottom = boundry.bottom
      right = boundry.right

      _.each _.rest(@contentItems), (contentItem) ->
        boundry = contentItem.getBoundry()


        top = Math.min(top, boundry.top)
        left = Math.min(left, boundry.left)
        bottom = Math.max(bottom, boundry.bottom)
        right = Math.max(right, boundry.right)


      # console.log 'top', top

      # topOffset += top
      # # console.log topDiff
      # leftOffset += left

      topDiff = top
      leftDiff = left

      top += topOffset
      left += leftOffset
      bottom += topOffset
      right += leftOffset


      boundry = new Newstime.Boundry(top: top, left: left, bottom: bottom, right: right)
      @model.set _.pick(boundry, 'top', 'left', 'width', 'height'), silent: true

      _.each @contentItems, (contentItem) ->
        contentItem.set
          top: Math.max(contentItem.get('top') - topDiff, 0)
          left: Math.max(contentItem.get('left') - leftDiff, 0)


      @getPorps()

      @model.trigger 'change'
      # @model.trigger 'change:height'

  measurePosition: ->
    @contentItems = _.pluck @contentItemViewsArray, 'model'
    first = _.first(@contentItems)
    if first?
      boundry =  first.getBoundry()

      top = boundry.top
      left = boundry.left
      bottom = boundry.bottom
      right = boundry.right

      _.each @contentItems, (contentItem) ->
        boundry = contentItem.getBoundry()

        top = Math.min(top, boundry.top)
        left = Math.min(left, boundry.left)
        bottom = Math.max(bottom, boundry.bottom)
        right = Math.max(right, boundry.right)

      boundry = new Newstime.Boundry(top: top, left: left, bottom: bottom, right: right)
      @model.set _.pick boundry, 'top', 'left', 'width', 'height'

  keydown: (e) =>
    switch e.keyCode
      when 85 # u
        @ungroup() if e.altKey
      else
        super(e)

  ungroup: ->
    contentItems = @contentItemViewsArray.slice(0) # Clone array of items.
    _.each contentItems.reverse(), (canvasItem) =>
      @removeCanvasItem(canvasItem)
      @composer.canvas.addCanvasItem(canvasItem)

    @composer.canvas.removeCanvasItem(this)
    @deselect()

    @composer.select.apply(@composer, contentItems)

    @composer.deleteQueue.push @model # Push model onto delete queue for destruction with next save.
    @remove() # Remove view

  delete: ->
    # Delete group contents as well.
    contentItems = @contentItemViewsArray.slice(0) # Clone array of items.
    _.each contentItems, (canvasItem) =>
      canvasItem.delete()
    super

  # getHitContentItem: (x, y) ->
  #   if y >= @boundingBox.top && y <= @boundingBox.bottom
  #     # If x,y hits the bounding box, check hit against contentItemsArray
  #     _.find @contentItemViewsArray, (contentItemView) ->
  #       contentItemView.hit(x, y, buffer: 24)

  class MouseEvents

    mousedown: (e) ->
      return unless e.button == 0 # Only respond to left button mousedown.

      unless @selected
        if e.shiftKey
          # Add to selection
          @composer.addToSelection(this)
        else
          @composer.select(this) # TODO: Shift+click with add to selection. alt-click will remove from.
      else
        if e.shiftKey
          # Remove from selection
          @composer.removeFromSelection(this)

      # Pass mouse down to selection
      @composer.activeSelectionView.trigger 'mousedown', e

    mousemove: (e) ->

      if @opened
        # TODO: Map mouse move over grouped items.
        # console.log e.x, e.y

        groupBoundry = @getBoundry()

        x = e.x - groupBoundry.top
        y = e.y - groupBoundry.left

        event = new Newstime.Event(e)
        [event.x, event.y] = [x, y] # Map event coordinates

        selection = null

        selection = _.find @contentItemViewsArray, (contentItemView) ->
          contentItemView.hit(x, y, buffer: 24)

        if selection
          if @hoveredObject != selection
            if @hoveredObject
              @hoveredObject.trigger 'mouseout', event
            @hoveredObject = selection
            # alert @hoveredObject
            @hoveredObject.trigger 'mouseover', event
        else
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', event
            @hoveredObject = null

        if @hoveredObject
          @hoveredObject.trigger 'mousemove', event

    mouseover: (e) ->
      @hovered = true
      @outlineView.show()
      @composer.pushCursor @getCursor()

    mouseout: (e) ->
      if @hoveredHandle
        @hoveredHandle.trigger 'mouseout', e
        @hoveredHandle = null

      @hovered = false
      @outlineView.hide()
      @composer.popCursor()

    dblclick: (e) ->
      if @opened
        if @hoveredObject
          @hoveredObject.trigger 'dblclick'

      else
        @openGroup()

  tap: (e) ->
    # {x, y} = e.center
    {pageX: x, pageY: y} = e.pointers[0]

    if @opened
      # {top, left} = @getBoundry()
      top = @model.getOffsetTop()
      left = @model.getOffsetLeft()

      x -= top
      y -= left

      selection = null

      selection = _.find @contentItemViewsArray, (contentItemView) ->
        contentItemView.hit(x, y, buffer: 24)

      if selection
        selection.trigger 'tap', e #{center: {x, y}}

    else
      super

  doubletap: (e) ->
    super
    if @opened
    else

      # {x, y} = e.center
      {pageX: x, pageY: y} = e.pointers[0]

      # @openGroup()
      # {top, left} = @getBoundry()
      top = @model.getOffsetTop() + 62
      left = @model.getOffsetLeft()

      x -= left
      y -= top

      selection = null

      selection = _.find @contentItemViewsArray, (contentItemView) ->
        contentItemView.hit(x, y, buffer: 8)

      console.log 'selection', selection

      if selection
        selection.trigger 'tap', e #{center: {x, y}, pointers: [{pageX: x, pageY: y}] }


  # class TouchEvents

  # tap: (e) ->
  #   super
  #   @composer.select(this)

    # touchstart: (e) ->
    #   @composer.select(this)
    #   @composer.activeSelectionView.trigger 'touchstart', e


  if MOBILE?
    # @include TouchEvents
  else
    @include MouseEvents

  openGroup: ->
    @composer.canvas.openGroup(this)
    @opened = true

  closeGroup: ->
    if @opened
      @trigger 'close-group', this
      @opened = false

  toggleLeftBorder: ->
    @leftBorder = @model.get('left_border')

    if @leftBorder
      @removeLeftBorder()
    else
      @addLeftBorder()

  # Add Left Border
  addLeftBorder: ->
    @model.set 'left_border', true
    @leftBorder = true

    @$el.addClass 'group-left-border'

    # For each item, push in 15px (1px add for border, total of 16px)
    _.each @contentItemViewsArray, (contentItemView) ->
      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.needsReflow = true

      model = contentItemView.model
      left = model.get('left')
      if left < 15
        delta = 16 - left
        model.set
          left: 15
          width: model.get('width') - delta

      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.reflow()

  # Remove Left Border
  removeLeftBorder: ->
    @model.set 'left_border', false
    @leftBorder = false

    @$el.removeClass 'group-left-border'

    # For each item, push in 15px (1px add for border, total of 16px)
    _.each @contentItemViewsArray, (contentItemView) ->

      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.needsReflow = true

      model = contentItemView.model
      left = model.get('left')
      if left = 15
        model.set
          left: 0
          width: model.get('width') + 16

      if contentItemView instanceof Newstime.TextAreaView
        contentItemView.reflow()

  _setBoundry: (boundry)->
    current = @getBoundry()

    # Get difference
    topDelta = boundry.top - current.top
    leftDelta = boundry.left - current.left

    # Apply Difference
    _.each @contentItemViewsArray, (canvasItem) ->
      canvasItem.model.set
        top: canvasItem.model.get('top') - topDelta
        left: canvasItem.model.get('left') - leftDelta

    @model.set _.pick(boundry, 'top', 'left', 'width', 'height')

  _createModel: (attrs={}) ->
    @edition.groups.add(attrs)

  _createPropertiesView: ->
    new Newstime.GroupPropertiesView(groupView: this, groupModel: @model)
