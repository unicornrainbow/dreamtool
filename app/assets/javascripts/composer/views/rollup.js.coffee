#= require ../views/panel_view
@Dreamtool = Dreamtool or {}

class @Dreamtool.Rollup extends Newstime.PanelView

  initialize: (options) ->
    super
    @$el.addClass('rollup')
    # $/+class el 'rollup'
    @model.set('bottom', 0)

  render: ->
    @$el.css @model.pick('width', 'top', 'bottom', 'left', 'right')
    @$el.css 'z-index': @model.get('z_index')
    @$el.toggle !@hidden
    @$el.toggleClass 'unhooked', @unhooked
    @renderPanel() if @renderPanel

  move: (x, y) ->
    if @hooked
      @unhooked = @startTop - y + @topMouseOffset > 70

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
    _.defaults position, { top: null, left: null, right: null }
    @model.set position

  beginDrag: (e) ->
    super
    @$el.removeClass('rolledUp')
    @startTop = @model.get('top')

  endDrag: (e) ->
    super

    unless @hooked
      @hooked = true
      @model.set
        top: @model.get('top') + 33
    else
      if @startTop - @model.get('top') > 70
        @rollup()
      else
        # reset
        @model.set
          top: @startTop

  rollup: ->
    @$el.addClass('rolledUp')
    @hooked = false
    @unhooked = false
    @model.set
      top: window.innerHeight - 90
