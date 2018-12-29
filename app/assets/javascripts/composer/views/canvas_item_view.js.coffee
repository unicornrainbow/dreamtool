#= require ../mixins/draggable
#
# CanvasItemView are CanvasItems which can appear on the canvas, or within a
# canvas like region like a group. Both ContentItemView and GroupViews are
# CanvasItemViews.
#
class @Newstime.CanvasItemView extends @Newstime.View
  @include Newstime.Draggable

  initialize: (options={}) ->
    @addClassNames()

    @composer ?= Newstime.composer
    @edition  ?= @composer.edition

    @model ?= @_createModel()

    @propertiesView ?= @_createPropertiesView()

    @outlineView = @composer.outlineViewCollection.add
                     model: @model

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove


    @bindUIEvents()

    @initializeCanvasItem()

  keydown: (e) =>
    switch e.keyCode
      when 8 # del
        if confirm "Are you sure you wish to delete this item?"
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
      when 27 # ESC
        @deselect()
      when 219 # [
        if e.altKey
          if e.shiftKey
            @pageView.sendToBack(this)
          else
            @pageView.sendBackward(this)
      when 221 # ]
        if e.altKey
          if e.shiftKey
            @pageView.bringToFront(this)
          else
            @pageView.bringForward(this)

  # class TouchEvents

  tap: (e) ->
    unless @selected
      if @composer.multiSelectionMode
        @composer.addToSelection(this)
      else
        # console.log 'select', this
        @composer.select(this)
    else
      unless @tapped
        tapped = =>
          # Single tap should clear selection.
          @tapped = null

          if @composer.multiSelectionMode
            if @composer.selection instanceof Newstime.MultiSelectionView and
                 @composer.selection.selectedViews.length > 1

              @composer.removeFromSelection(this)
            else
              @composer.exitMultiSelect()
              # @removeClass 'multi-selected'
              # @composer.exitMultiSelect()
              # @composer.select(this)

          else
            # If grouped, return selection to group.
            if @groupView
              @composer.select(@groupView)
            else
              @composer.clearSelection()


        @tapped = setTimeout(tapped, 300)

  doubletap: (e) ->
    if @tapped
      # console.log @tapped
      # dbltap... cancel tap
      clearTimeout(@tapped)
      @tapped = null


  press: (e) ->
    unless @groupView
      if @composer.multiSelectionMode
        @composer.addToSelection(this)
      else
        if @selected and e.pointers.length == 2
          @composer.multiSelect()


  addClassNames: ->
    @$el.addClass @className

  render: ->
    @$el.css @model.pick 'width', 'height', 'top', 'left'

    @$el.css 'z-index': @model.get('z_index')

  # Deletes the content item
  delete: ->
    @deselect() if @selected
    if @container
      @container.removeCanvasItem(this)
    @composer.deleteQueue.push @model
    @remove()

  remove: ->
    @composer.pagesPanelView?.render() # HACK: This should be done in a more central manner.
    super

  @getter 'top',  -> @model.get('top')
  @getter 'left', -> @model.get('left')
  @getter 'pageView', -> @_pageView
  @getter 'uiLabel', -> 'Canvas Item'

  @setter 'pageView', (value) ->
    @_pageView = value
    if value && value.model.id
      @model.set(page_id: value.model.id)

  getPropertiesView: ->
    @propertiesView

  select: (selectionView) ->
    #unless @selected
    @selected = true
    @selectionView = selectionView

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this

  setSizeAndPosition: (attributes) ->
    @model.set(attributes)

  setElement: (el) ->
    super
    @addClassNames()

  # Sets model values.
  set: ->
    @model.set.apply(@model, arguments)

  getCursor: ->
    'default'

  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  getBoundry: ->
    @model.getBoundry()

  hit: ->
    @model.hit.apply(@model, arguments)

  setPageView: (pageView) ->
    @pageView = pageView
