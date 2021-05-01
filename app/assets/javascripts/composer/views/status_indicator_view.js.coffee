
class @Newstime.StatusIndicatorView extends Backbone.View # Would be better named status indicator and use it to tell about save progress

  initialize: (options) ->
    @$el.addClass 'status-indicator'
    @$el.html """
      <div class="unsaved-changes-indicator">&bull;</div>
      <div class="status-indicator-message"></div>
    """

    @$unsavedChanges = @$(".unsaved-changes-indicator")
    @$message = @$(".status-indicator-message")

    @unsavedChanged false
    @hide()



  unsavedChanged: (val) ->
    @$unsavedChanges.toggleClass 'fade-out', !val

  showMessage: (msg, hideAfter) ->
    if @hideAfterTimeout
      clearTimeout(@hideAfterTimeout)
      @hideAfterTimeout = null

    @$message.html msg
    if msg?
      @show()
    else
      @hide()

    if hideAfter
      @hideAfterTimeout = @clear
      setTimeout @clear, hideAfter

  clear: =>
    @hideAfterTimeout = null
    @hide()


  show: ->
    @$message.removeClass 'fade-out'

  hide: ->
    @$message.addClass 'fade-out'
