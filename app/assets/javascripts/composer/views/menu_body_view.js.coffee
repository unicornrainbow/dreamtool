class @Newstime.MenuBodyView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-body"

    @composer = Newstime.composer

    @$el.hide()

    @model = new Backbone.Model()

    @attachedMenuItem = []

    @composer = Newstime.composer

    @boundry = new Newstime.Boundry()

    @listenTo @model, 'change', @render
    @listenTo @model, 'change', @updateBoundry
    @render()

    @bindUIEvents()

  render: ->
    @$el.css @model.pick 'top', 'left'

  updateBoundry: ->
    #_.extend @boundry, @model.pick 'top', 'left'
    @boundry.top = @model.get('top')
    @boundry.left = @model.get('left')

    @boundry.width = @$el.width()
    @boundry.height = @$el.height()

  open: ->
    @$el.show()
    @updateBoundry()
    _.invoke @attachedMenuItem, 'updateBoundry'
    @composer.menuLayerView.cutout.addBoundry(@boundry)

  close: ->
    @$el.hide()
    @composer.menuLayerView.cutout.removeBoundry(@boundry)

  attachMenuItem: (menuItemView) ->
    @attachedMenuItem.push(menuItemView)
    @$el.append(menuItemView.el)

  mousemove: (e) ->
    e = @getMappedEvent(e)

    hover = null

    unless hover
      # NOTE: Would be nice to skip active selection here, since already
      # checked, but no biggie.
      _.find @attachedMenuItem, (menuItemView) ->
        if menuItemView.boundry.hit(e.x, e.y)
          hover = menuItemView

    if hover
      if @hoveredObject != hover
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
        @hoveredObject = hover
        @hoveredObject.trigger 'mouseover', e
    else
      if @hoveredObject
        @hoveredObject.trigger 'mouseout', e
        @hoveredObject = null

    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e

  mouseover: (e) ->
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e)->
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'mouseout', e


  mousedown: (e)->
    e = @getMappedEvent(e)

    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e


  # Coverts external to internal coordinates.
  mapExternalCoords: (x, y) ->
    y -= @model.get('top')
    x -= @model.get('left')

    return [x, y]

  # Returns a wrapper event with external coords mapped to internal.
  # Note: Wrapping the event prevents modifying coordinates on the orginal
  # event. Stop propagation and prevent are called through to the wrapped event.
  getMappedEvent: (event) ->
    event = new Newstime.Event(event)
    [event.x, event.y] = @mapExternalCoords(event.x, event.y)
    return event
