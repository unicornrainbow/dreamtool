class @Newstime.PanelView extends @Newstime.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'
   'mousemove': 'dOMMousemove'
   'keydown': 'keydown'
   'paste': 'paste'
   'mousedown .dismiss': 'dismiss'
   'mousedown': 'mousedown'
   'click': 'click'

  initialize: (options) ->
    @$el.addClass('newstime-palette-view')

    @composer = Newstime.composer
    @panelLayerView = @composer.panelLayerView

    @model ?= new Newstime.Panel

    @$el.html """
      <div class="title-bar">
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
    """

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    @initializePanel(options)

    @bindUIEvents()

    @listenTo @model, 'change', @render

    @render()


  mousedown: ->
    @panelLayerView.bringToFront(this)

  render: ->
    @$el.css @model.pick('width', 'height')
    @$el.css 'z-index': @model.get('z_index')
    @renderPanel() if @renderPanel

  dismiss: (e) ->
    @hide()
    @composer.panelLayerView.hoveredObject = null

    @hovered = false
    @$el.removeClass 'hovered'

    @composer.captureLayerView.engage()
    @composer.unlockScroll()


  keydown: (e) ->
    e.stopPropagation() #

    switch e.keyCode
      when 27 #ESC
        # Send focus back to composer.
        @composer.focus()
      when 83 # s
        if e.altKey
          e.preventDefault()
          @composer.edition.save()


  paste: (e) ->
    e.stopPropagation()


  mouseover: (e) =>
    @hovered = true
    @$el.addClass 'hovered'

    # Make foremost


    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

    @composer.lockScroll()

    # Disengage capture layer to decieve mouse events directly.
    @composer.captureLayerView.disengage()


  mouseout: (e) =>
    @hovered = false
    @$el.removeClass 'hovered'

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null

    @composer.captureLayerView.engage()
    @composer.unlockScroll()

  dOMMousemove: (e) ->
    e.stopPropagation()

  hide: ->
    @hidden = true
    @$el.hide()

  show: ->
    @hidden = false
    @$el.show()

  mousemove: (e) ->
    e.y += @composer.panelLayerView.topOffset

    if @tracking
      @$el.css('bottom', $(window).height() - e.y - @bottomMouseOffset)
      @$el.css('right', $(window).width() - e.x - @rightMouseOffset)

  mouseup: (e) ->
    if @tracking
      @tracking = false
      @trigger 'tracking-release', this
      @composer.popCursor()
      @mouseover(e)
      @endDrag()


  beginDrag: (e) ->
    if e.target == @$titleBar[0]
      @dragging = true
      @$titleBar.addClass('grabbing')

      # Calulate offsets
      @bottomMouseOffset = $(window).height() - e.clientY - parseInt(@$el.css('bottom'))
      @rightMouseOffset =  $(window).width() - e.clientX - parseInt(@$el.css('right'))

      # Engage and begin tracking here.

      @tracking = true
      @composer.pushCursor('-webkit-grabbing')
      @trigger 'tracking', this
      @composer.captureLayerView.engage()

  endDrag: (e) ->
    if @dragging
      @dragging = false
      @$titleBar.removeClass('grabbing')

  # Attachs html or element to body of palette
  attach: (html) ->
    @$body.html(html)

  setPosition: (bottom, right) ->
    #@$el.css(top: top, left: left)
    @$el.css(bottom: bottom, right: right)

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    #parseInt(@$el.css('left'))
    #@$el[0].offsetLeft
    #Math.round(@$el.position().left)
    #Math.round(
    Math.round(@$el.offset().left)
    #@$el[0].getBoundingClientRect()


  y: ->
    @$el[0].offsetTop

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  clear: ->
    @$body.empty()

  click: (e) ->
    # Stop porpagation of clicks so the do not reach the panel view layer, which would rengage the capture view layer.
    e.stopPropagation()

  setZIndex: (index) ->
    @model.set 'z_index', index

  # Reset panel to default state.
  reset: ->
    @hovered = false
    @$el.removeClass 'hovered'
