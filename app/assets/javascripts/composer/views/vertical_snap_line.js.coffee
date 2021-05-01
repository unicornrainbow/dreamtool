# Covers and capture mouse events for relay to interested objects.
class @Newstime.VerticalSnapLine extends Backbone.View

  initialize: (options) ->
    @$el.addClass "vertical-snap-line"
    @zoomLevel = 1

  show: ->
    @$el.show()

  hide: ->
    @$el.hide()

  render: ->
    @$el.css left: (@left * @zoomLevel)

  set: (left) ->
    @left = left

  setZoomLevel: (zoomLevel) ->
    @zoomLevel = zoomLevel
