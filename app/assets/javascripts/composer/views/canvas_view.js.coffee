class @Newstime.CanvasView extends @Newstime.View

  # Searches within itemView for view with client id
  _findWithinGroupView: (cid, itemView) ->
    view = null
    _.find itemView.contentItemViewsArray, (itemView) =>
      if itemView.cid == cid
        view = itemView
      else
        if itemView instanceof Newstime.GroupView
          view = @_findWithinGroupView(cid, itemView)

    return view

  # Assigns a view to a page in the pageViewsArray (Note: pageViewsArray should
  # become a special collection.
  _assignPage: (view, options={}) ->
    # Determine page based on intersection.
    pageView = _.find @pageViewsArray, (pageView) =>
      @detectHitY pageView, view.model.get('top')

    # HACK, If no page view was found, assign to first page.
    unless pageView
      pageView = @pageViewsArray[0]

    pageView.addCanvasItem(view, options)

  addCanvasItem: (view, options={}) ->
    view.container = this
    @$canvasItems.append(view.el)
    @composer.outlineLayerView.attach(view.outlineView)
    @_assignPage(view, options)
    @trigger 'change'

  #addGroup: (group) ->
    #@groupViews[group.cid] =
      #new Newstime.GroupView
        #model: group

  addPage: (pageModel) ->
    pageModel.getHTML (html) =>
      el = $(html)[0]
      @$grid.append(el)

      pageView = new Newstime.PageView
        el: el
        page: pageModel

      @pages.push pageView

      pageView.bind 'tracking', @tracking, this
      pageView.bind 'tracking-release', @trackingRelease, this

  append: (el) ->
    @$el.append(el)

  changeEditionPageColor: ->
    resolvedColor = @edition.get('colors').resolve(@edition.get('page_color'))
    @$el.css 'background-color', resolvedColor

  contextmenu: (e) ->
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'contextmenu', e

  dblclick: (e) ->
    e = @getMappedEvent(e)

    if @openedGroup? && @hoveredObject != @openedGroup
      @clearOpenedGroup()
      return true

    if @hoveredObject
      @hoveredObject.trigger 'dblclick', e


  detachView: (view) ->
    # Find page with view.
    pageView = _.find @pageViewsArray, (pageView) ->
      pageView.hasView(view)

    # Detach from page.
    pageView.detachView(view)

  detectHit: (page, x, y) ->
    geometry = page.geometry()

    # The x value that comes back needs to have this xCorrection value applied
    # to it to make it right. Seems to be due to a bug in jQuery that has to do
    # with the zoom property. This works for now to get the correct offset
    # value.
    if @zoomLevel
      xCorrection = Math.round(($(window).scrollLeft()/@zoomLevel) * (@zoomLevel - 1))
    else
      xCorrection = 0

    geometry.x -= xCorrection


    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 8 # 2px
    geometry.x -= buffer
    geometry.y -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    if x >= geometry.x && x <= geometry.x + geometry.width
      if y >= geometry.y && y <= geometry.y + geometry.height
        return true

    return false

  detectHitY: (page, y) ->
    geometry = page.geometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.y -= buffer
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    if y >= geometry.y && y <= geometry.y + geometry.height
      return true

    return false

  draw: (type, x, y) ->
    view = new type()
    view.model.set(top: y, left: x)
    @addCanvasItem(view)
    @composer.select(view)
    @composer.selection.beginDraw(x, y)

    view.serverRender()

  drawPath: (x, y) ->
    pathView = new Dreamtool.DrawingView
    @addCanvasItem(view)
    pathView.enterDrawingMode()
    pathView.addPoint(x, y)

    # @drawingPath = new Dreamtool.Path
    # @drawingPath.setStartingPoint(x, y)
    # @captureDrawing()
    # @trigger 'tracking', this

  drawSelection: (x, y) ->
    selectionView = new Newstime.Selection()
    @$el.append(selectionView.el)

    selectionView.bind 'tracking', @resizeSelection, this
    selectionView.bind 'tracking-release', @resizeSelectionRelease, this

    selectionView.beginSelection(x, y)

  extractHeadlinesViews: (el) ->
    els = $('[headline-control]', el).detach()
    _.map els, (el) =>
      id = $(el).data('content-item-id')
      model = @contentItemCollection.findWhere(_id: id)
      new Newstime.HeadlineView
        el: el
        model: model
        composer: @composer

  # findViewByCID
  #
  # Description: Takes a cid (Client ID), and finds and returns the associated
  # view from within the page structure. Searches all pages and groups.
  findViewByCID: (cid) =>
    view = null
    _.find @pageViewsArray, (pageView) =>
      if pageView.cid == cid
        view = pageView
      else
        _.find pageView.contentItemViewsArray, (itemView) =>
          if itemView.cid == cid
            view = itemView
          else
            if itemView instanceof Newstime.GroupView
              view = @_findWithinGroupView(cid, itemView)

    return view

  getCursor: ->
    cursor = switch @toolbox.get('selectedTool')
      when 'select-tool' then 'default'
      when 'type-tool' then "-webkit-image-set(url('/images/type_tool_cursor.png') 1x), auto"
      when 'headline-tool' then "-webkit-image-set(url('/images/headline_tool_cursor.png') 1x), auto"
      when 'photo-tool' then "-webkit-image-set(url('/images/photo_tool_cursor.png') 1x), auto"
      when 'video-tool' then "-webkit-image-set(url('/images/video_tool_cursor.png') 1x), auto"
      when 'divider-tool' then "-webkit-image-set(url('/images/divider_tool_cursor.png') 1x), auto"

    #when 'text-tool' then 'pointer'
    #when 'text-tool' then 'text'

  # Returns a wrapper event with external coords mapped to internal.
  # Note: Wrapping the event prevents modifying coordinates on the orginal
  # event. Stop propagation and prevent are called through to the wrapped event.
  getMappedEvent: (event) ->
    event = new Newstime.Event(event)                         # Wrap event in a newstime event object, copies coords.
    [event.x, event.y] = @mapExternalCoords(event.x, event.y) # Map coordinates
    return event                                              # Return event with mapped coords.

  getMappedTouchEvent: (event) ->
    event = new Dreamtool.TouchEvent(event)
    i=0
    while i < event.touches.length
      touch = event.touches.item(i)
      [touch.x, touch.y] = @mapExternalCoords(touch.x, touch.y)
      i++
    return event

  handlePageFocus: (page) ->
    @focusedPage = page
    @trigger 'focus', this

  hit: (x, y) ->
    return true # Since canvas is the bottom-most layer, we assume everything hits it if asked.

  initialize: (options) ->
    @composer = Newstime.composer
    { @topOffset,
      @edition,
      @toolbox,
      @toolsSpinner} = options

    # Capture Elements
    @$window = $(window)
    @$document = $(document)
    @$body = $('body')

    @$el.css top: "#{@topOffset}px"
    @$el.addClass 'canvas-view'

    @contentItemCollection = @edition.get('content_items')
    @groupCollection       = @edition.get('groups')

    # Capture all the pages & content items
    @contentItemSelector = '[data-content-item-id]'
    @groupSelector       = '[data-group-id]'
    @pageSelector        = '[data-page-id]'

    contentItemEls     = @$(@contentItemSelector).detach()
    groupEls           = @$(@groupSelector).detach()
    pageEls            = @$(@pageSelector).detach()

    @$pages = @$('[pages]') # Pages container

    @pageViews = options.pageViews
    @pageContentItems = {}                          # Inventory of content items per each page
    @pageGroups = {}                                # Inventory of content items per each page
    @groupViews = options.groupViews                # Group views by group.cid
    @contentItemViews = options.contentItemViews
    @contentItemOutlineViews = {}

    ## Add each of the pages back, rebuilding the view in the correct order.
    ## Need pages for this section, ordered by page number.
    @pages = new Backbone.Collection(section.getPages())


    @pageViewsArray = [] # Order array of the page views. # TODO: Should be a special collection.

    @pages.each (page) =>
      page_id = page.id
      el = pageEls.filter("[data-page-id='#{page_id}']")

      view = new Newstime.PageView
        el: el
        model: page

      @$pages.append(el)

      view.capturePageBounds()

      @pageViews[page.cid] = view
      @pageViewsArray.push(view)
      @pageContentItems[page.cid] = page.getContentItems()
      @pageGroups[page.cid] = page.getGroups()

      @listenTo view, 'change', => @trigger 'change'


    @$canvasItems = $('<div class="canvas-items"></div>')
    @$canvasItems.appendTo(@$body)

    # Attach a view to draw the link
    @$linkAreas = $('<div class="link-areas"></div>')
    @$linkAreas.appendTo(@$body)

    # Position canvas items div layer
    @positionCanvasItemsContainer()

    @$masthead = @$('.masthead')
    @mastheadView = new Newstime.MastheadView
      composer: @composer
      el: @$masthead[0]

    @composer.outlineLayerView.attach(@mastheadView.outlineView)

    @pages.each (page) =>
      pageID = page.get('_id')
      pageView = @pageViews[page.cid]

      groups = @pageGroups[page.cid]
      contentItems = @pageContentItems[page.cid]

      # Validate contentItem group reference, clear group_id if group not found
      _.each contentItems, (item) ->
        if item.get('group_id')
          unless _.findWhere(groups, id: item.get('group_id'))
            item.unset('group_id') # Clear group, since it was not found.

      # Only process top level groups
      groups = _.reject groups, (group) -> group.get('group_id')

      # For each group top level group, construct and add in each grouped
      # content item.

      constructGroup = (group, parentView) =>

        # Get the group id, and the group element.
        id = group.get('_id')
        el = groupEls.filter("[data-group-id='#{id}")

        # Create a groupView, passing in, to reuse, the group el.
        groupView = new Newstime.GroupView
          model: group
          el: el

        if typeof parentView == 'object'
          parentView.addCanvasItem(groupView, reattach: true) # Add groupView to the canvas.
        else
          @addCanvasItem(groupView, reattach: true) # Add groupView to the canvas.

        # Retrive the group content items from the group object.
        groupItems = group.getItems()

        # Order the groupContentItems by z-index, highest to lowest.
        groupItems = groupItems.sort (a, b) ->
          b.get('z_index') - a.get('z_index') # Reverese order on z-index (Highest towards top)


        # Add grouped content items to group
        _.each groupItems, (item) ->

          if item.get('_type') == "Group"
            constructGroup(item, groupView)

          else

            # Construct and add in each content item.
            id = item.get('_id')
            el = contentItemEls.filter("[data-content-item-id='#{id}")

            contentItemType = item.get('_type')

            ## What is the content items type?
            contentItemViewType =
              switch contentItemType
                when 'HeadlineContentItem' then Newstime.HeadlineView
                when 'TextAreaContentItem' then Newstime.TextAreaView
                when 'PhotoContentItem' then Newstime.PhotoView
                when 'VideoContentItem' then Newstime.VideoView
                when 'DividerContentItem' then Newstime.DividerView
                when 'HTMLContentItem' then Newstime.HTMLView

            contentItemView = new contentItemViewType
              model: item
              el: el

            groupView.addCanvasItem(contentItemView, reattach: true)

            contentItemView.render()

        #@listenTo group, 'destroy', (group) ->
          #@groupViews[group.cid] = null

        #groupCID = group.cid
        #@groupViews[group.id] = groupView
        #@groupOutlineViews[groupCID] = groupOutlineView

        #@$groups.append(el) # For now a seperate layer, eventually on canvas item div, with z-index coordination

        #@composer.outlineLayerView.attach(groupView.outlineView)



      _.each groups, constructGroup


      # Don't process items which are part of a group
      contentItems = _.reject contentItems, (item) -> item.get('group_id')

      _.each contentItems, (contentItem) =>
        # Construct and add in each content item.
        id = contentItem.get('_id')
        el = contentItemEls.filter("[data-content-item-id='#{id}']")

        contentItemType = contentItem.get('_type')

        ## What is the content items type?
        contentItemViewType =
          switch contentItemType
            when 'HeadlineContentItem' then Newstime.HeadlineView
            when 'TextAreaContentItem' then Newstime.TextAreaView
            when 'PhotoContentItem' then Newstime.PhotoView
            when 'VideoContentItem' then Newstime.VideoView
            when 'DividerContentItem' then Newstime.DividerView
            when 'HTMLContentItem' then Newstime.HTMLView

        contentItemView = new contentItemViewType
          model: contentItem
          el: el

        @addCanvasItem(contentItemView, reattach: true)

        contentItemView.render()


    # Add an add page button
    @addPageButton = new Newstime.AddPageButton
      composer: @composer
    @$el.append(@addPageButton.el)

    # Create link area, to enable clicking through on links.
    @linkAreas = _.map @$el.find('a'), (link) =>
      new Newstime.LinkArea(link, topOffset: @topOffset, composer: @composer)

    _.each @linkAreas, (linkArea) =>
      view = new Newstime.LinkAreaView
        model: linkArea
      view.render()
      @$linkAreas.append(view.el)

    @bindUIEvents()

    @listenTo @composer, 'zoom', @zoom
    @listenTo @composer, 'windowResize', @positionCanvasItemsContainer
    @listenTo @contentItemCollection, 'remove', @removeContentItem
    @listenTo @groupCollection, 'add', @addGroup

    @listenTo @edition, 'change:page_color', @changeEditionPageColor


    _.each @groupViews, (groupView) ->
      groupView.measurePosition()
      groupView.render()

  # Inserts view before referenceView.
  insertBefore: (view, referenceView) ->
    # Find page with view.
    pageView = _.find @pageViewsArray, (pageView) ->
      pageView.hasView(referenceView)

    # Insert before on page.
    pageView.insertBefore(view, referenceView)

  keydown: (e) ->
    if @composer.activeSelection
      @composer.activeSelection.trigger 'keydown', e

  # Coverts external to internal coordinates.
  mapExternalCoords: (x, y) ->
    # Apply pages offset, to focus on draw surface.
    y -= @pagesOffset.top
    x -= @pagesOffset.left

    # Apply scroll offset
    x += $(window).scrollLeft()
    y += $(window).scrollTop()

    # Apply zoom
    if @zoomLevel
      x = Math.round(x/@zoomLevel)
      y = Math.round(y/@zoomLevel)

    return [x, y]

  # Measure link areas. Right now, need to do this after render to ensure we get
  # to correct values. Should be improved.
  measureLinks: =>
    _.invoke @linkAreas, 'measure', @position

  touchstart: (e) ->
    # console.log "touch start", e

    e = @getMappedTouchEvent(e)

    touch = e.touches[0]
    {x, y} = touch

    @touchOffsetY = e.touches[0].clientY
    @scrollTop = Math.round($(window).scrollTop())
    @scrollSpeed = 0

    clearInterval(@scrollInterval) if @scrollInterval

    selection = null

    if @toolsSpinner.get('selectedTool')
      switch @toolsSpinner.get('selectedTool')
        when 'story-tool'
          @draw(Newstime.TextAreaView, x, y)
          @toolsSpinner.set('selectedTool', null)
        when 'headline-tool'
          @draw(Newstime.HeadlineView, x, y)
          @toolsSpinner.set('selectedTool', null)
        when 'photo-tool'
          @draw(Newstime.PhotoView, x, y)
          @toolsSpinner.set('selectedTool', null)
    else
      # if @touching
      #   unless @touching.hit(x, y)
      #     @touching = null

      if @composer.selection # Check active selection first.
        if @composer.selection.group # react differently if the selection is inside of a group
          group = @composer.selection.group
          selection = @composer.selection if @composer.selection.hit(x - group.get('left'), y - group.get('top'))
        else
          selection = @composer.selection if @composer.selection.hit(x, y)

      # unless selection
      #   _.find @pageViewsArray, (pageView) ->
      #     selection = pageView.getHitContentItem(x, y)

      @touching = selection

      if @touching
        @touching.trigger 'touchstart', e


    # else
    #   @composer.clearSelection()

    # console.log touching: @touching

    # if @hovered

  tap: (e) ->
    [x, y] = @mapExternalCoords(e.center.x, e.center.y)

    selection = null

    if @composer.selection # Check active selection first.
      if @composer.selection.group
        group = @composer.selection.group
        selection = @composer.selection if @composer.selection.hit(x - group.get('left'), y - group.get('top'))
      else
        selection = @composer.selection if @composer.selection.hit(x, y)

    unless selection
      _.find @pageViewsArray, (pageView) ->
        selection = pageView.getHitContentItem(x, y)

    if selection
      selection.trigger 'tap', e


  doubletap: (e) ->
    [x, y] = @mapExternalCoords(e.center.x, e.center.y)

    selection = null

    if @composer.selection # Check active selection first.
      if @composer.selection.group
        group = @composer.selection.group
        selection = @composer.selection if @composer.selection.hit(x - group.get('left'), y - group.get('top'))
      else
        selection = @composer.selection if @composer.selection.hit(x, y)
    # unless selection
    #   _.find @pageViewsArray, (pageView) ->
    #     selection = pageView.getHitContentItem(x, y)

    if selection
      selection.trigger 'doubletap', e

  press: (e) ->
    {x, y} = e.center
    [x, y] = @mapExternalCoords(x, y)

    selection = null

    if @composer.selection # Check active selection first.
      if @composer.selection.group
        group = @composer.selection.group
        selection = @composer.selection if @composer.selection.hit(x - group.get('left'), y - group.get('top'))
      else
        selection = @composer.selection if @composer.selection.hit(x, y)
    unless selection
      _.find @pageViewsArray, (pageView) ->
        selection = pageView.getHitContentItem(x, y)

    if selection
      selection.trigger 'press', e

  touchmove: (e) ->
    e = @getMappedTouchEvent(e)

    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'touchmove', e
      return true

    # Scroll
    documentHeight = Math.round(document.body.scrollHeight)
    # @scrollTop   = Math.round($(window).scrollTop())


    @scrollSpeed = (@touchOffsetY - e.touches[0].clientY)
    @scrollTop += @scrollSpeed
    @touchOffsetY = e.touches[0].clientY

    $(window).scrollTop(@scrollTop)

    # console.log "scroll", e

  touchend: (e) ->
    e = @getMappedTouchEvent(e)
    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'touchend', e
      return true

    # console.log
    speed = @scrollSpeed * 2
    scrollTop = @scrollTop
    start = Date.now()
    duration = 1.2

    @scrollInterval = id = setInterval ->
      t = (Date.now() - start)/(duration * 1000)
      # console.log (speed * duration*10) * (1-(1-t)*(1-t))
      # console.log 1-(1-t)*(1-t)

      # speed
      # scrollTop - (1-t) * speed

      # $(window).scrollTop scrollTop - ((speed * 20) / t*t)
      $(window).scrollTop scrollTop + (speed * duration*10) * (1-(1-t)*(1-t))
      # $(window).scrollTop scrollTop + (speed * duration*10) * t*(2-t)

      clearInterval(id) if t > 1
    , 27

  mousedown: (e) ->
    return unless e.which == 1 # Only draw with left click

    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e
    else
      switch @toolbox.get('selectedTool')
        when 'type-tool'
          @draw(Newstime.TextAreaView, e.x, e.y)
        when 'headline-tool'
          @draw(Newstime.HeadlineView, e.x, e.y)
        when 'photo-tool'
          @draw(Newstime.PhotoView, e.x, e.y)
        when 'video-tool'
          @draw(Newstime.VideoView, e.x, e.y)
        when 'divider-tool'
          @draw(Newstime.DividerView, e.x, e.y)
        when 'html-tool'
          @draw(Newstime.HTMLView, e.x, e.y)
        when 'path-tool'
          @drawPath(e.x, e.y)
        when 'select-tool'
          if e.button == 0 # Only on left click
            @composer.clearSelection()
          #@drawSelection(e.x, e.y)

  mousemove: (e) ->
    # Create a new event with corrdinates relative to the canvasItemsView
    e = @getMappedEvent(e)

    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mousemove', e
      return true

    if @openedGroup
      @openedGroup.trigger 'mousemove', e
      return true

    selection = null

    # Check for hit inorder to highlight hovered selection
    if @composer.activeSelectionView # Check active selection first.
      selection = @composer.activeSelectionView if @composer.activeSelectionView.hit(e.x, e.y)

    unless selection
      _.find @pageViewsArray, (pageView) ->
        selection = pageView.getHitContentItem(e.x, e.y)

    unless selection
      # NOTE: Would be nice to skip active selection here, since already
      # checked, but no biggie.
      selection = _.find @linkAreas, (linkArea) ->
        linkArea.hit(e.x, e.y)

    unless selection # If no page, check for button hit
      if @detectHit @addPageButton, e.x, e.y
        selection = @addPageButton

    unless selection
      if @detectHit @mastheadView, e.x, e.y
        selection = @mastheadView

    if selection
      if @hoveredObject != selection
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
        @hoveredObject = selection
        @hoveredObject.trigger 'mouseover', e
    else
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', e
        @hoveredObject = null

    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e

  mouseout: (e) ->
    @hovered = false
    e = @getMappedEvent(e)
    @popCursor()
    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

  mouseover: (e) ->
    @hovered = true
    e = @getMappedEvent(e)
    @pushCursor() # Replace with hover stack implementation eventually

    # Seems redundant. Isn't this already happening in mousemove?
    # if @hoveredObject
    #   @hoveredObject.trigger 'mouseover', e

  mouseup: (e) ->
    e = @getMappedEvent(e)

    if @resizeSelectionTarget
      @resizeSelectionTarget.trigger 'mouseup', e
      return true

    if @trackingSelection
      @trackingSelection = null # TODO: Should still be active, just not tracking
      @trigger 'tracking-release', this

    #if @trackingPage
      #@trackingPage.trigger 'mouseup', e
      #return true

  paste: (e) ->
    if @composer.activeSelection
      @composer.activeSelection.trigger 'paste', e

  popCursor: ->
    @composer.popCursor()

  # Update canvas item container to overlay pages.
  positionCanvasItemsContainer: ->
    # console.log 'lucky'
    # TODO: Move this functionality up to the composer
    @pagesOffset = @$pages.offset()
    @pagesOffset.height = @$pages.height()
    @pagesOffset.width = @$pages.width()
    @position = _.clone(@pagesOffset)

    # Dezoom
    if @zoomLevel
      @position.height = @pagesOffset.height/@zoomLevel
      @position.width = @pagesOffset.width/@zoomLevel

      @position.left -= (@position.width - @pagesOffset.width)/2

    @$canvasItems.css(@position)
    @$linkAreas.css(@position)

    @composer.outlineLayerView.setPosition @position
    @composer.selectionLayerView.setPosition @position

  pushCursor: ->
    @composer.pushCursor(@getCursor())

  openGroup: (group) ->
    @openedGroup = group
    @listenTo @openedGroup, 'close-group', @clearOpenedGroup

  clearOpenedGroup: ->
    @stopListening @openedGroup
    @openedGroup.closeGroup()
    @openedGroup = null

  removeCanvasItem: (view) ->
    view.$el.detach()
    @composer.outlineLayerView.remove(view.outlineView)
    view.pageView.removeCanvasItem(view)
    view.container = null
    @trigger 'change'

  removeContentItem: (contentItem) =>
    # Remove from the content items view registry.
    delete @contentItemViews[contentItem.cid]
    delete @contentItemOutlineViews[contentItem.cid]

  removePage: (pageView) ->
    pageView.$el.detach()
    index = @pageViewsArray.indexOf(pageView)
    if index == -1
      throw "Page view not found."
    @pageViewsArray.splice(index, 1)
    pageView.container = null
    @trigger 'change'

  render: ->
    @measureLinks()
    @trigger 'render'

  resizeSelection: (selection) ->
    @resizeSelectionTarget = selection
    @trigger 'tracking', this

  resizeSelectionRelease: (selection) ->
    @resizeSelectionTarget = null
    @trigger 'tracking-release', this

  # Saves changes to canvas
  save: ->
    _.each @pageViewsArray, (pageView) ->
      pageView.save()
    #@edition.save()

  selectContentItem: (e) ->

    selection = new Newstime.ContentItemSelection
      contentItem: e.contentItem
      contentItemView: e.contentItemView

    @composer.setSelection(selection)
    @trigger 'focus', this # Trigger focus event to get keyboard events

  selectionDeactivated: (selection) ->
    @composer.clearSelection()

  tracking: (page) ->
    @trackingPage = page
    @trigger 'tracking', this

  trackingRelease: (page) ->
    @trackingPage = null
    @trigger 'tracking-release', this

  windowResize: ->
    @positionCanvasItemsContainer()

    #@canvasItemsView.setPosition(@pagesView.getPosition())
    #_.each @pages, (page) =>
      #page.trigger 'windowResize'

    #_.each @selectionViews, (item) =>
      #item.trigger 'windowResize'

  # Handler for updating view after a zoom change.
  zoom: ->
    @zoomLevel = @composer.zoomLevel

    transform = 'transform': "scale(#{@zoomLevel})"
    @$el.css(transform)
    @$canvasItems.css(transform)

    @positionCanvasItemsContainer()
