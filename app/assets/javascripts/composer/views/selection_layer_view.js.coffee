class @Newstime.SelectionLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-layer-view'

    @composer = options.composer

    @composer.bind 'zoom', @zoom, this

  setPosition: (position) ->
    @position = position
    @computeZoomedPosition()
    @render()

  zoom: ->
    @zoomLevel = @composer.zoomLevel
    @computeZoomedPosition()
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

  render: ->
    @$el.css @zoomedPosition
    if @currentSelectionView
      @currentSelectionView.render()


  setSelection: (selectionView) ->
    @currentSelectionView = selectionView

    @$el.empty()
    @$el.append @currentSelectionView.el
