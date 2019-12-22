
class @Newstime.PanelView extends @Newstime.View

  events:
    'mousedown .title-bar': 'titleBarMousedown'
    'mouseup .title-bar': 'titleBarMouseup'
    'mousemove .title-bar': 'titleBarMousemove'
    'mousedown .resize-scrub': 'beginResizeDrag'
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
        <span class="tu dismiss"></span>
        <span class="tu mini-maxi"></span>
      </div>
      <div class="palette-body">
      </div>
      <span class="resize-scrub"></span>
    """

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')
    @$resizeScrub = @$el.find('.resize-scrub')

    @initializePanel(options)

    @bindUIEvents()

    @listenTo @model, 'change:hidden', @changeHidden
    @listenTo @model, 'change', @render

    @render()


  mousedown: ->
    @panelLayerView.bringToFront(this)

  changeHidden: ->
    @hidden = @model.get('hidden')

  render: ->
    @$el.css @model.pick('width', 'height')
    @$el.css @model.pick('right', 'left', 'bottom', 'top')

    @$el.css 'z-index': @model.get('z_index')
    @$el.toggle !@hidden
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
          @composer.save()


  paste: (e) ->
    e.stopPropagation()

  mouseover: (e) =>

    # alert @model.get('height')
    # alert @$body.children().first().height()
    #mini maxi mode
    # @model.get('mini/height')
    # @model.get('mini/width')
    # @model.get('maxi/height')
    # @model.get('maxi/width')
    # h = @$body.children().first().height()
    # # (get model.height)
    # @model.set(height: h + 30)

    @hovered = true
    @$el.addClass 'hovered'

    @_titleBarMousedown = false # Reset flag

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
    @model.set(hidden: true)

  show: ->
    @model.set(hidden: false)

  toggle: ->
    if @hidden then @show() else @hide()

  mousemove: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    y += @composer.panelLayerView.topOffset

    if @tracking
      if @dragging
        @move(x, y)

      if @resizing
        @resize(x, y)

  move: (x, y) ->
    # x -= @leftMouseOffset
    y -= @topMouseOffset

    positionBy = @model.get('positionBy') || ['right', 'top']

    if x - @leftMouseOffset + @model.get('width')/2 < $(window).width()/2
      # Position left
      positionBy[0] = 'left'
      x -= @leftMouseOffset
    else
      # Position right
      positionBy[0] = 'right'
      x = $(window).width() - x - @rightMouseOffset

    if positionBy[1] == 'bottom'
      y = $(window).height() - y - @bottomMouseOffset
    position = _.object positionBy, [x, y]
    _.defaults position, { top: null, bottom: null, left: null, right: null }
    # console.log position
    @model.set position

  resize: (x, y) ->
    @model.set
      width: x - @model.get('left') + @rightMouseOffset
      height: y - @model.get('top') + @bottomMouseOffset

  mouseup: (e) ->
    if @tracking
      @tracking = false
      @trigger 'tracking-release', this

      if @dragging
        @composer.popCursor()
        @mouseover(e)
        @endDrag()

      if @resizing
        @mouseover(e)
        @endResizeDrag()

  titleBarMousedown: ->
    @_titleBarMousedown = true

  titleBarMouseup: ->
    @_titleBarMousedown = false

  titleBarMousemove: (e) ->
    if @_titleBarMousedown
      @_titleBarMousedown = false
      @beginDrag(e)

  beginDrag: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    if e.target == @$titleBar[0]
      @dragging = true
      @$titleBar.addClass('grabbing')

      @leftMouseOffset = x - @x() #@model.get('left')
      @topMouseOffset = y - @model.get('top')
      @rightMouseOffset = @model.get('width') - @leftMouseOffset
      @bottomMouseOffset = @model.get('height') - @topMouseOffset

      # Engage and begin tracking here.

      @tracking = true
      @composer.pushCursor('-webkit-grabbing')
      @trigger 'tracking', this
      @composer.captureLayerView.engage()

  endDrag: (e) ->
    if @dragging
      @dragging = false
      @$titleBar.removeClass('grabbing')

  beginResizeDrag: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    if e.target == @$resizeScrub[0]
      @resizing = true

      # Calulate offsets
      @leftMouseOffset = x - @model.get('left')
      @topMouseOffset = y - @model.get('top')
      @rightMouseOffset = @model.get('width') - @leftMouseOffset
      @bottomMouseOffset = @model.get('height') - @topMouseOffset

      # Engage and begin tracking here.

      @tracking = true
      @trigger 'tracking', this
      @composer.captureLayerView.engage()

  endResizeDrag: (e) ->
    if @resizing
      @resizing = false

  # Attachs html or element to body of palette
  attach: (html) ->
    @$body.html(html)

  setPosition: (bottom, right) ->
    @model.set
      top: $(window).height() - bottom - @model.get('height')
      left: $(window).width() - right - @model.get('width')
    #@$el.css(top: top, left: left)
    #@$el.css(bottom: bottom, right: right)

  setPositionTopLeft: (top, left) ->
    @model.set
      top: top
      left: left

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    if @model.get('left')
      @model.get('left')
    else
      $(window).width() - @model.get('right') - @model.get('width')

  y: ->
    @model.get('top')

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

  getSettings: ->
    @model.pick('top', 'left', 'bottom', 'right'
      'positionBy',
      'height', 'width')

  setSettings: (settings) ->
    @model.set(settings)
