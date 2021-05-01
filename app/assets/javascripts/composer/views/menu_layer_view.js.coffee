# View layer which manages display and interaction with panels
class @Newstime.MenuLayerView extends Newstime.View

  initialize: (options) ->
    @addClass 'menu-layer-view'

    { @composer, @menuHeight } = options

    @attachedViews = []

    @cutout = new Newstime.ComplexBoundry()

    @width = 1184

    # Draw shape for main menu area
    @mainAreaBoundry = new Newstime.Boundry(top: 0, left: 0, width: @width, height: @menuHeight)
    @cutout.addBoundry(@mainAreaBoundry)

    @menuView = new Newstime.MenuView()
    @attach(@menuView)

    # Draw boundry for testing
    #boundryView = new Newstime.BoundryView(model: @mainAreaBoundry)
    #@$el.append(boundryView.el)

    @bindUIEvents()

    @bind 'attach', @handelAttach
    @listenTo @composer, 'windowResize', @handelWindowResize

  hit: (x, y) ->
    x -= @menuView.leftOffset
    @cutout.hit(x, y)

  mousemove: (e) ->
    @menuView.trigger 'mousemove', e

  mouseover: (e) ->
    @menuView.trigger 'mouseover', e

  mouseout: (e) ->
    @menuView.trigger 'mouseout', e

  mousedown: (e) ->
    @menuView.trigger 'mousedown', e

  mouseup: (e) ->
    @menuView.trigger 'mouseup', e

  touchstart: (e) ->
    @menuView.trigger 'touchstart', e

  touchend: (e) ->
    @menuView.trigger 'touchend', e

  touchmove: (e) ->
    @menuView.trigger 'touchmove', e

  tap: (e) ->
    @menuView.trigger 'tap', e

  press: (e) ->
    @menuView.trigger 'press', e

  click: (e) ->
    @menuView.trigger 'click', e

  attach: (view) ->
    @attachedViews.push(view)
    @$el.append(view.el)
    view.trigger 'attach'

  handelAttach: ->
    _.each @attachedViews, (v) -> v.trigger 'attach'

  handelWindowResize: ->
    _.each @attachedViews, (v) -> v.trigger 'windowResize'
