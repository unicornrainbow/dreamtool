# Covers and capture mouse events for relay to interested objects.
class @Newstime.CaptureLayerView extends Backbone.View

  events:
    'mousemove': 'mousemove'
    'mouseout': 'mouseout'
    'mousedown': 'mousedown'
    'mouseup': 'mouseup'
    'click': 'click'
    'dblclick': 'dblclick'
    'contextmenu': 'contextmenu'
    'touchstart': 'touchstart'
    'touchmove': 'touchmove'
    'touchend': 'touchend'

  initialize: (options) ->
    @$el.addClass "capture-layer-view"

    @mc = new Hammer(@el,
      inputClass: Hammer.TouchInput
    )
    @mc.on 'tap', @tap
    @mc.on 'doubletap', @doubletap
    @mc.on 'press', @press

    @topOffset = options.topOffset # Apply top offset (Allows room for menu)
    @composer = options.composer

    # Capture mouseups that happen off screen http://stackoverflow.com/a/5419564/32384
    $(window).mouseup @mouseup
    $(document).mouseout @documentMouseout

    # document.body.addEventListener 'touchmove', null, false;

    document.body.addEventListener 'touchmove',
      (e)->e.preventDefault(),
      {passive: false};

    @$el.css top: "#{@topOffset}px"

  contextmenu: (e) ->
    @trigger "contextmenu", e

  mousedown: (e) ->
    e.stopPropagation()
    @trigger 'mousedown', e
    #switch e.which
      #when 1 # Left button
        #@trigger 'mousedown', e

  mouseup: (e) =>
    e.stopPropagation()
    @trigger 'mouseup', e


  mousemove: (e) ->
    e.stopPropagation()
    @trigger 'mousemove', e


  click: (e) ->
    e.stopPropagation()
    @trigger 'click', e


  dblclick: (e) ->
    e.stopPropagation()
    @trigger 'dblclick', e


  mouseout: (e) ->
    e.stopPropagation()
    @trigger 'mouseout', e

  touchstart: (e) ->
    e.stopPropagation()
    @trigger 'touchstart', e

  touchmove: (e) ->
    e.stopPropagation()
    @trigger 'touchmove', e

  touchend: (e) ->
    e.stopPropagation()
    @trigger 'touchend', e

  touchcancel: (e) ->
    e.stopPropagation()
    @trigger 'touchcancel', e

  tap: (e) =>
    #e.stopPropagation()
    @trigger 'tap', e

  doubletap: (e) =>
    #e.stopPropagation()
    @trigger 'doubletap', e

  press: (e) =>
    #e.stopPropagation()
    @trigger 'press', e

  hideCursor: ->
    @$el.css
      cursor: 'none'

  showCursor: ->
    @$el.css
      cursor: ''

  changeCursor: (cursor) ->
    @$el.css(cursor: cursor)

  engage: ->
    @$el.css 'pointer-events': ''
    @$el.show()

  disengage: ->
    @$el.css 'pointer-events': 'none'
    @$el.hide()

  reset: ->
    @engage()

  documentMouseout: (e) =>
    # Rudementary check to see if leaving window
    if e.relatedTarget == null
      # If leaving the document window, reset the composer.
      # (This only triggers is the capture layer is disengage, other wise the event would be swollowed)
      @composer.reset(e)
