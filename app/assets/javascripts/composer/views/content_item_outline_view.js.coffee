
class @Newstime.ContentItemOutlineView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'content-item-outline-view'

    @composer = Newstime.composer

    @pageOffsetLeft = options.pageOffsetLeft || 0
    @pageOffsetTop  = options.pageOffsetTop || 0

    @$el.css
      top:  @model.get('top') + @pageOffsetTop
      left: @model.get('left') + @pageOffsetLeft

    @$el.css _.pick @model.attributes, 'width', 'height'

    @listenTo @model, 'change', @render

  show: ->
    @$el.addClass 'outline'

  hide: ->
    @$el.removeClass 'outline'

  render: ->
    position = _.pick @model.attributes, 'width', 'height'

    position.top = @model.get('top')
    position.top += @pageOffsetTop

    position.left = @model.get('left')
    position.left += @pageOffsetLeft

    # Apply zoom level
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel

      position.height *= zoomLevel
      position.width *= zoomLevel
      position.top *= zoomLevel
      position.left *= zoomLevel

    @$el.css(position)
