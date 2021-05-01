@Newstime = @Newstime || {}

class @Newstime.ToolboxButtonView extends Backbone.View
  initialize: (options) ->
    @type = options.type

    @toolbox = options.toolbox

    @$el.addClass "toolbox-button"
    @$el.addClass @type

    @$el.css options.position

    @geometry =
      top: parseInt(options.position.top)
      left: parseInt(options.position.left)
      height: 30
      width: 30


    @toolbox.bind 'change:selectedTool', @selectedToolChanged, this

    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout
    @bind 'mousedown', @mousedown

  selectedToolChanged: ->
    @selected = @toolbox.get('selectedTool') == @type
    @$el.toggleClass 'selected', @selected

  # Detects a hit of the selection
  hit: (x, y) ->
    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 2 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height

  getGeometry: ->
    _.pick @geometry , 'top', 'left', 'width', 'height'

  mouseover: (e) ->
    @hovered = true
    @$el.addClass 'hovered'

  mouseout: (e) ->
    @hovered = false
    @$el.removeClass 'hovered'

  mousedown: (e) ->
    @select()

  select: ->
    @toolbox.set selectedTool: @type
