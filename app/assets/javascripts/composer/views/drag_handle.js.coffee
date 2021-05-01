@Newstime = @Newstime || {}

class @Newstime.DragHandle extends Backbone.View

  initialize: (options) ->
    @type = options.type
    @selection = options.selection

    @$el.addClass 'drag-handle'
    @$el.addClass @type

    @bind 'mouseover', @mouseover
    @bind 'mouseout', @mouseout

  # Detects a hit of the selection
  hit: (x, y) ->
    x = e.x
    y = e.y

    geometry = @selection.getGeometry()

    switch @type

      when 'top' # top drag handle hit?
        x >= geometry.x + geometry.width/2 - 8 &&
          x <= geometry.x + geometry.width/2 + 8 &&
          y >= geometry.y - 8 &&
          y <= geometry.y + 8

  selected: ->
    @$el.addClass 'selected'

  reset: ->
    @$el.removeClass 'selected'

  mouseover: ->
    @$el.addClass 'hovered'

  mouseout: ->
    @$el.removeClass 'hovered'
