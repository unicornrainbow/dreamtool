@Newstime = @Newstime || {}

class @Newstime.PageView extends @Newstime.View

  initialize: (options) ->

    @composer = Newstime.composer
    @edition = @composer.edition

    @model ?= @_createModel()
    @toolbox = options.toolbox
    @$el.addClass 'page-compose'

    @boundingBox = new Newstime.Boundry(@model.pick('top', 'left', 'bottom', 'right'))
    @contentItemViewsArray = []

    @contentItemsSelector = "[headline-control], [text-area-control], [photo-control], [video-control], [divider-control]"

    @page = @model

    @listenTo @model, 'destroy', @pageDestroyed

    @contextMenu = new Newstime.PageContextMenu
      page: @model
    @$el.append(@contextMenu.el)


    @propertiesView ?= @_createPropertiesView()

    #@gridLines = new Newstime.GridLines()
    #@$el.append(@gridLines.el)

    @pageBorder = new Newstime.PageBorder(page: this)
    #@$el.append(@pageBorder.el)
    #@pageBorder.modelChanged()

    #@setPageBorderDimensions()
    #console.log @pageBorder.model

    @grid = new Newstime.GridView
    @$el.append(@grid.el)

    @bindUIEvents()

  setPageBorderDimensions: ->
    # The page border needs to know the x and y location of the page. It also
    # needs to know the page width and height, and finally it needs to know the
    # margins for each of the four sides, from this is can compute it's top,
    # left, right and bottom dimensions for rendering relative to the canvas
    # view layer.
    geometry = @geometry()
    console.log geometry
    @pageBorder.model.set
      pageX: geometry.x
      pageY: geometry.y
      pageWidth:  geometry.width
      pageHeight: geometry.height
      pageTopMargin: 4 # TODO: These values need to be set and read from the page model.
      pageLeftMargin: 8
      pageRightMargin: 8
      pageBottomMargin: 4



  @getter 'uiLabel', -> "Page #{@model.get('number')}"

  keydown: (e) =>
    switch e.keyCode
      when 8 # del
        if confirm "Are you sure you wish to delete this page?"
          @delete()
        e.stopPropagation()
        e.preventDefault()
      when 27 # ESC
        @deselect()

  delete: ->
    # Delete page contents
    contentItems = @contentItemViewsArray.slice(0) # Clone array of items.
    _.each contentItems, (canvasItem) =>
      canvasItem.delete()
    @deselect()

    # Remove page from canvas
    @composer.canvas.removePage(this)

    @composer.deleteQueue.push @model
    @remove()

    @composer.canvas.positionCanvasItemsContainer()
    @composer.pagesPanelView.renderPanel()


  deselect: ->
    if @composer.selection == this
      @composer.clearSelection()

  getPropertiesView: ->
    @propertiesView

  # Add content item to the top of the page.
  # TODO: Delete me - see add()
  #addContentItem: (contentItemView) ->
    ## Get content item view, and place on top of contentItemsViewArray, update
    ## z-indexs
    #contentItem = contentItemView.model
    #@contentItemViewsArray.unshift(contentItemView)

    ## Set page z-index within page
    #contentItem.set('z_index', @contentItemViewsArray.length-1)

    ## Expand page bounding box if neccessary
    #contentItemBoundry = contentItem.getBoundry()
    #if contentItemBoundry.bottom > @boundingBox.bottom
      #@boundingBox.bottom = contentItemBoundry.bottom

  save: ->
    @model.save()

  # Add view to page
  addCanvasItem: (view, options={}) ->
    index = options.index

    if options.reattach
      index = view.model.get('z_index')

    # view.pageView = this
    view.setPageView this

    # Note: contentItemViewsArray should be a special collection.

    # Get content item view, and place on top of contentItemsViewArray, update
    # z-indexs
    if _.isNumber(index)
      index = Math.min @contentItemViewsArray.length, index

      @contentItemViewsArray.splice(@contentItemViewsArray.length-index, 0, view)

      # Set page z-index within page
      #view.model.set('z_index', index)

      @updateZindexs()

    else
      @contentItemViewsArray.unshift(view)

      # Set page z-index within page
      view.model.set('z_index', @contentItemViewsArray.length-1)

    # Expand page bounding box if neccessary
    contentItemBoundry = view.getBoundry()
    if contentItemBoundry.bottom > @boundingBox.bottom
      @boundingBox.bottom = contentItemBoundry.bottom


  removeCanvasItem: (view) ->
    # Note: contentItemViewsArray should be a special collection.

    index = @contentItemViewsArray.indexOf(view)
    if index == -1
      throw "Content Item not part of page."

    @contentItemViewsArray.splice(index, 1)
    view.pageView = null

    # Update z-indexs
    @updateZindexs()

    # TODO: Adjust expanded page bounding box

  # Inserts content item at specified index
  insertContentItemAtIndex: (contentItemView, index) ->
    @contentItemViewsArray.splice(index, 0, contentItemView)

    # Update z-indexs
    @updateZindexs()

  windowResize: ->
    #@setPageBorderDimensions()

  getHitContentItem: (x, y) ->
    if y >= @boundingBox.top && y <= @boundingBox.bottom
      # If x,y hits the bounding box, check hit against contentItemsArray
      _.find @contentItemViewsArray, (contentItemView) ->
        contentItemView.hit(x, y)

  # Inserts view before referenceView.
  insertBefore: (view, referenceView) ->
    # Find index on view
    index = _.indexOf @contentItemViewsArray, referenceView

    # Insert View at point.
    @insertContentItemAtIndex(view, index)

  hasView: (view) ->
    _.contains(@contentItemViewsArray, view)

  detachView: (view) ->
    # Find index on view
    index = _.indexOf @contentItemViewsArray, view

    @contentItemViewsArray.splice(index, 1)

    # Update z-indexs
    @updateZindexs()


  updateZindexs: ->
    length = @contentItemViewsArray.length - 1
    _.each @contentItemViewsArray, (view, index) ->
      view.model.set('z_index', length - index)

    @composer.vent.trigger 'page:canvas-items-reorder', this

  bringForward: (contentItemView) ->
    # Discover the index in the contentItemViewsArray
    index = _.indexOf @contentItemViewsArray, contentItemView

    # Move forward if possible
    if index > 0
      [@contentItemViewsArray[index], @contentItemViewsArray[index-1]] = [@contentItemViewsArray[index-1], @contentItemViewsArray[index]]

    # Update z-indexs
    @updateZindexs()


  sendBackward: (contentItemView) ->
    # Discover the index in the contentItemViewsArray
    index = _.indexOf @contentItemViewsArray, contentItemView

    # Move down if possible
    if index + 1 < @contentItemViewsArray.length
      [@contentItemViewsArray[index], @contentItemViewsArray[index+1]] = [@contentItemViewsArray[index+1], @contentItemViewsArray[index]]

    # Update z-indexs
    @updateZindexs()


  bringToFront: (contentItemView) ->
    # Discover the index in the contentItemViewsArray
    index = _.indexOf @contentItemViewsArray, contentItemView

    # Move to front if not already there
    if index != 0
      view = @contentItemViewsArray.splice(index, 1)[0]
      @contentItemViewsArray.unshift(view)

    # Update z-indexs
    @updateZindexs()

  sendToBack: (contentItemView) ->
    # Discover the index in the contentItemViewsArray
    index = _.indexOf @contentItemViewsArray, contentItemView

    # Move to front if not already there
    if index != @contentItemViewsArray.length - 1
      view = @contentItemViewsArray.splice(index, 1)[0]
      @contentItemViewsArray.push(view)

    # Update z-indexs
    @updateZindexs()


  # Sets up and compute grid steps
  gridInit: ->
    ## TODO: Get the offset to be on the grid steps
    columnWidth = 34
    gutterWidth = 16
    columns = 24

    ## Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    @leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    @rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  # Relative to screen
  x: ->
    #parseInt(@$el.css('left'))
    #@$el[0].offsetLeft
    #Math.round(@$el.position().left)
    #Math.round(
    #@$el[0].getBoundingClientRect()
    Math.round(@$el.offset().left)

  y: ->
    @el.offsetTop

  # Return top relative offset from containing element
  getOffsetTop: ->
    @el.offsetTop

  # Return left relative offset from containing element
  getOffsetLeft: ->
    @el.offsetLeft

  capturePageBounds: ->
    @model.set(@calculatePageBounds())
    @boundingBox = new Newstime.Boundry(@model.pick('top', 'left', 'bottom', 'right'))

  calculatePageBounds: ->
    top = @el.offsetTop
    left = @el.offsetLeft
    width = @width()
    height = @height()

    {
      'top': top
      'left': left
      'bottom': top + height
      'right': left + width
    }

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()


  # Applies offset (sort of a hack for now)
  adjustEventXY: (e) ->
    # Apply scroll offset
    e.x -= @x()
    e.y -= @y()


  ## Event Handlers

  dblclick: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.

    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    if @hoveredObject
      # Pass on mousedown to hovered object
      @hoveredObject.trigger 'dblclick', e

  contextmenu: (e) ->
    e.preventDefault() # Cancel default context menu

    @adjustEventXY(e) # Could be nice to abstract this one layer up...

    @composer.displayContextMenu @contextMenu

    @contextMenu.show(e.x, e.y)


  snapLeft: (value) ->
    unless @composer.snapEnabled then return null

    snapTolerance  = 20
    # Get snap values
    gridSnap = @grid.snapLeft(value)
    pageLeftEdge = @pageBorder.model.get('pageLeftMargin')
    canvasItemSnap = Newstime.closest(value, @pageContentItemLeftEdges)

    # Find closest of snaps
    snapTo = Newstime.closest(value , [gridSnap, pageLeftEdge, canvasItemSnap])

    # Only use snap if snap is within tolerance
    if Math.abs(snapTo - value) < snapTolerance
      snapTo
    else
      null

  getLeftSnapPoints: ->
    # TODO: Consider all snap points, not just grid...
    @grid.leftSteps

  getRightSnapPoints: ->
    # TODO: Consider all snap points, not just grid...
    @grid.rightSnapPoints

  snapRight: (value) ->
    unless @composer.snapEnabled then return null

    snapTolerance  = 20
    # Get snap values
    gridSnap = @grid.snapRight(value)

    #pageLeftEdge = @pageBorder.model.get('pageLeftMargin')
    #canvasItemSnap = Newstime.closest(value, @pageContentItemLeftEdges)

    # Find closest of snaps
    snapTo = Newstime.closest(value , [gridSnap])

    # Only use snap if snap is within tolerance
    if Math.abs(snapTo - value) < snapTolerance
      snapTo
    else
      null

  stepLeft: (value) ->
    @grid.stepLeft(value)
    #value

  stepRight: (value) ->
    @grid.stepRight(value)
    #value

  snapTop: (value) ->
    #closest = Newstime.closest(value, @topSnapPoints)
    #if Math.abs(closest - value) < 10 then closest else value
    # Math.max value, 0

    value

  getWidth: ->
    @grid.pageWidth

  snapBottom: (value) ->
    #closest = Newstime.closest(value, @bottomSnapPoints)
    #if Math.abs(closest - value) < 10 then closest else value
    value
  pageDestroyed: ->
    # TODO: Need to properly unbind events and allow destruction of view
    @$el.remove()


  moveItem: (target, x, y, orginalX, orginalY, shiftKey=false) ->
    @composer.clearVerticalSnapLines()
    geometry = target.getGeometry()

    if shiftKey
      # In which direction has the greatest movement.
      lockPlain = if Math.abs(x - orginalX) > Math.abs(y - orginalY) then 'x' else 'y'

    switch lockPlain
      when 'x'
        # Move only in x direction
        target.setSizeAndPosition
          left: x
          top: orginalY
      when 'y'
        # Move only in y direction
        target.setSizeAndPosition
          left: orginalX
          top: y
      else
        #x = Math.min(x, @pageView.getWidth() - @model.get('width')) # Keep on page
        snapLeft = @snapLeft(x) # Snap

        if snapLeft
          x = snapLeft
          @composer.drawVerticalSnapLine(x)
        else
          @composer.clearVerticalSnapLines()

        # Show matching right snap edge
        right = x + geometry.width - 8
        snapRight = @snapRight(right) # Snap

        if snapRight == right
          @composer.drawVerticalSnapLine(snapRight + 8)

        y = @snapTop(y)

        target.setSizeAndPosition
          left: x
          top: y

  # Computes top snap points
  computeTopSnapPoints: ->
    @topSnapPoints = _.map @selectionViews, (view) ->
      view.getTop()

  computeBottomSnapPoints: ->
    @bottomSnapPoints = _.map @selectionViews, (view) ->
      view.getTop() + view.getHeight()


  # Collects left edges of canvas items on page
  #
  # If item passed as exclude, it will be excluded
  collectLeftEdges: (exclude=null) ->
    items = @page.getContentItems()
    if exclude
      items = _.reject items, (item) -> item.get('_id') == exclude.get('_id')
    @pageContentItemLeftEdges = _.map(items, (item) -> item.get('left'))

  # Extracts all content items from the page. Useful in decomposing the views.
  extractContentItems: ->
    @$(@contentItemsSelector).detach()


  # Collects right edges of canvas items on page
  #
  # If item passed as exclude, it will be excluded
  collectRightEdges: (exclude=null) ->
    items = @page.getContentItems()
    if exclude
      items = _.reject items, (item) -> item.get('_id') == exclude.get('_id')
    @pageContentItemRightEdges = _.map(items, (item) -> item.get('left') + item.get('width'))

  # Experimental: Get's attached item that should be move when the vertical
  # height of an objects is changed.
  getAttachedItems: (item) ->
    a = item.getBoundry()

    attachedItems = []
    # Get all items below boundry, but within left to right
    _.each @model.getContentItems(), (contentItem) ->
      b = contentItem.getBoundry()
      if a.bottom < b.top && a.left <= b.left && a.right >= b.right
        attachedItems.push [contentItem, {
          offsetTop: b.top - a.bottom
        }]

    attachedItems

  _createPropertiesView: ->
    new Newstime.PagePropertiesView(target: this, model: @model)

  _createModel: (attrs={}) ->
    @edition.pages.add(attrs)
