@Dreamtool ?= {}
class @Dreamtool.TouchEvent
  constructor: (orginalEvent) ->
    @orginalEvent = orginalEvent

    if @orginalEvent?
      @touches = @orginalEvent.touches
      # @changedTouches = @orignalEvent.changedTouches
      # @targetTouches = @orignalEvent.targetTouches

      @altKey = @orginalEvent.altKey
      @shiftKey = @orginalEvent.shiftKey
      @which    = @orginalEvent.which

  stopPropagation: ->
    # Pass call through to orginal event
    @orginalEvent.stopPropagation()

  preventDefault: ->
    # Pass call through to orginal event
    @orginalEvent.preventDefault()
