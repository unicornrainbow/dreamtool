class @Newstime.CanvasDragView extends Backbone.View

  initialize: (options) ->
    @engaged = false
    @composer = options.composer

  engage: ->
    unless @engaged
      @engaged = true

      # Hide the cursor
      @composer.hideCursor()

      # Show stand in cursor in place

      # NOTE: need to now be the focus of mouse actions until disengaged
      #
      # Create an event handler and push in on to the handler stack.
      #@trigger 'mouse'


      console.log "Canvas drag engaged"

  disengage: ->
    if @engaged
      @engaged = false
      @composer.showCursor()
      console.log "Canvas drag disengaged"

  reset: ->
    @disengage()
