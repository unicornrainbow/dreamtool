@Newstime = @Newstime || {}

class @Newstime.VerticalRulerView extends Backbone.View

  events:
    'mousedown': 'mousedown'
    'mouseleave': 'mouseleave'
    'mouseup': 'mouseup'


  initialize: (options) ->
    @$el.addClass "vertical-ruler"
    @_mousedown = false

    # When the mouse is down
    # And hasn't been released
    # And goes past the right edge
    # then a vertical guide is created
    # and focus is transfer to it in a mousedown state

  mousedown: ->
    @_mousedown = true
    false

  mouseup: ->
    if @_mousedown
      @_mousedown = false

  mouseleave: (e) ->
    if @_mousedown && e.pageX >= 20
      # Create a vertical guide
      verticalGuideline = new Newstime.VerticalGuidelineView()
      $('body').append(verticalGuideline.el)

      # Transfer control to guide
      @_mousedown = false
      verticalGuideline.activate()

    else
      @_mousedown = false

  newVerticalGuide: ->
    # When we get here, we will need to elegently transfer control to the
    # vertical guide, and leave the ruler as it was.
    # TODO: Work on transfer of control.
    #new @Newstime.VerticalGuideView()
    console.log "Test"

class @Newstime.VerticalGuidelineView extends Backbone.View

  events:
    'mouseup': 'mouseup'
    'mousedown': 'mousedown'

  initialize: (options) ->
    @$el.addClass "vertical-guideline"

  mousemove: (e) =>
    @$el.css(left: e.pageX)

  activate: ->
    $(window).mousemove(@mousemove)

  deactivate: ->
    $(window).unbind('mousemove', @mousemove)

  mousedown: ->
    @activate()
    false

  mouseup: ->
    @deactivate()
    false
