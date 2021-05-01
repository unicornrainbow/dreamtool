# View layer which manages display and interaction with panels
class @Newstime.PanelLayerView extends @Newstime.View

  events:
    'mousemove': 'dOMMousemove'
    'click': 'click'

  initialize: (options) ->
    @$el.addClass 'panel-layer-view'
    @composer = options.composer
    @panels ?= []

    # Until we have a better means of containg all the application layer, just
    # using this simple means to offset from the top.
    @topOffset = options.topOffset
    @$el.css top: "#{@topOffset}px"

    @bindUIEvents()

  attachPanel: (panel) ->
    # Push onto the panels collection.
    @panels.push panel

    panel.bind 'tracking', @tracking, this
    panel.bind 'tracking-release', @trackingRelease, this

    # Attach it to the dom el
    @$el.append(panel.el)

  detachPanel: (panel) ->
    #index = @panels.indexOf(panel)
    #if index != -1
      #@panels.splice(index, 1)

    #panel.unbind 'tracking', @tracking
    #panel.unbind 'tracking-release', @trackingRelease

    panel.$el.detach()

  # Returns true if panel is attached
  hasAttachedPanel: (panel) ->
    @panels.indexOf(panel) != -1


  bringToFront: (panel) ->
    # Brings the passed in panel to the front.

    # Find the panel
    index = @panels.indexOf(panel)

    # Change the order
    if index >= 0
      item = @panels.splice(index, 1) # Remove from location in array
      @panels.unshift(item[0]) # Put in first position

    # Apply z-indexes
    length = @panels.length - 1
    _.each @panels, (view, i) ->
      view.setZIndex(length - i)


  # Registers hit, and returns hit panel, should there be one.
  hit: (x, y) ->
    return false if @hidden # Can't be hit if hidden.

    y -= @topOffset

    e =
      x: x
      y: y
    # Received a mousedown event, check for a hit and to see if we need to pass
    # on to a panel.

    # Check against panels.
    # Panel are assumed to be in order from top most first (When selected, a
    # panel is moved to the top visually and in this stack

    panel = _.find @panels, (panel) =>
      @detectHit panel, x, y

    if @hovered # Only process events if hovered.
      if panel
        if @hoveredObject != panel
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', e
          @hoveredObject = panel
          @hoveredObject.trigger 'mouseover', e

        return true
      else
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
          @hoveredObject = null

        return false

    else
      if panel
        # Defer processing of events until we are declared the hovered object.
        @hoveredObject = panel
        return true
      else
        return false

  detectHit: (panel, x, y) ->
    return false if panel.hidden

    return panel.hit(x, y) if panel.hit

    # Get panel geometry
    geometry = panel.geometry()

    # Expand the geometry by buffer distance in each direction to extend
    # clickable area.
    buffer = 4 # 2px
    geometry.x -= buffer
    geometry.y -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    # Detect if corrds lie within the geometry
    if x >= geometry.x && x <= geometry.x + geometry.width
      if y >= geometry.y && y <= geometry.y + geometry.height
        return true

    return false

  touchstart: (e) ->
    e = @getMappedTouchEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'touchstart', e

  touchmove: (e) ->
    e = @getMappedTouchEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'touchmove', e

  touchend: (e) ->
    e = @getMappedTouchEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'touchend', e

  tap: (e) ->
    # e = @getMappedTouchEvent(e)
    e.center.y -= @topOffset

    if @hoveredObject
      @hoveredObject.trigger 'tap', e

  mouseover: (e) ->
    @adjustEventXY(e) # This should be localized to corrds, and isolated to this view. Since this is modifying a shared object, this leaks

    @hovered = true

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @adjustEventXY(e)

    @hovered = false

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e
      @hoveredObject = null


  mousedown: (e) ->
    @adjustEventXY(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e

  mouseup: (e) ->
    @adjustEventXY(e)

    if @trackingPanel
      @trackingPanel.trigger 'mouseup', e
      return true

    if @hoveredObject
      @hoveredObject.trigger 'mouseup', e

  mousemove: (e) ->
    @adjustEventXY(e)

    if @trackingPanel
      @trackingPanel.trigger 'mousemove', e
      return true

    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e

  dOMMousemove: (e) ->
    e =
      x: e.x
      y: e.y

    @adjustEventXY(e)

    unless @detectHit(@hoveredObject, e.x, e.y)
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', e
        @hoveredObject = null

  adjustEventXY: (e) ->
    e.y -= @topOffset

  # adjustTouchEventXY: (e) ->
    # e.touches[]


  tracking: (panel) ->
    @trackingPanel = panel
    @trigger 'tracking', this

  trackingRelease: (panel) ->
    @trackingPanel = null
    @trigger 'tracking-release', this

  # Toggles Visibility
  toggle: ->
    @hidden = !@hidden
    @$el.toggle(!@hidden)

  hide: ->
    @$el.hide()
    @hidden = true

  click: (e) ->
    # If receiving a click here, need to reengage the capture view layer. Probably means
    # it got left disengaged after interacting with a panel due to a missed event.
    @composer.reset(e)

  # Resets the panel layer, disengage any hovered states.
  reset: ->
    _.each @panels, (panel) ->

  mapExternalCoords: (x, y) ->
    [x, y-@topOffset]

  getMappedTouchEvent: (event) ->
    event = new Dreamtool.TouchEvent(event)
    i=0
    while i < event.touches.length
      touch = event.touches.item(i)
      [touch.x, touch.y] = @mapExternalCoords(touch.x, touch.y)
      i++

    return event
