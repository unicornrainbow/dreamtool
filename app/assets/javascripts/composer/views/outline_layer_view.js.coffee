class @Newstime.OutlineLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'outline-layer-view'

    @outlineViews = []
    @verticalSnapLines = []

    @composer = options.composer

    @listenTo @composer, 'zoom', @zoom


  zoom: ->
    @zoomLevel = @composer.zoomLevel
    @computeZoomedPosition()

    _.each @verticalSnapLines, (snapLine) =>
      snapLine.setZoomLevel(@zoomLevel)
      snapLine.render()

    @render()

  # Computes and sets the zoomed position.
  computeZoomedPosition: ->
    position = _.clone(@position)

    # Apply zoom
    if @zoomLevel
      rawHeight = position.height
      rawWidth = position.width

      position.height = rawHeight*@zoomLevel
      position.width = rawWidth*@zoomLevel

      position.left -= (position.width - rawWidth)/2.0

    @zoomedPosition = position


  setPosition: (position) ->
    @position = position
    @computeZoomedPosition()
    @render()

  render: ->
    @$el.css @zoomedPosition
    _.each @outlineViews, (view) -> view.render()

  attach: (outlineView) -> # Rename to add
    @outlineViews.push(outlineView)
    @$el.append(outlineView.el)

  remove: (outlineView) ->
    index = @outlineViews.indexOf(outlineView)
    @outlineViews.splice(index, 1)
    outlineView.$el.detach()

  drawVerticalSnapLine: (x) ->
    snapLine = new Newstime.VerticalSnapLine()
    @$el.append snapLine.el
    @verticalSnapLines.push(snapLine)

    snapLine.set(x)
    snapLine.setZoomLevel(@zoomLevel) if @zoomLevel
    snapLine.render()

  clearVerticalSnapLines: ->
    _.each @verticalSnapLines, (snapLine) ->
      snapLine.remove()

    @verticalSnapLines = []
