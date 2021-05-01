#= require ./content_item_view

class @Newstime.DividerView extends @Newstime.ContentItemView

  contentItemClassName: 'divider-view'

  initializeContentItem: ->
    #@setContentEl(options.contentEl) if options.contentEl
    #@modelChanged()

    @elementStyles = 'divider'


  @getter 'uiLabel', -> "Divider"


  render: ->
    orientation = @model.get('orientation')
    width       = @model.get('width')
    height      = @model.get('height')
    thickness   = @model.get('thickness') || "1"

    if thickness
      thickness   = thickness.split(' ')
      thickness   = _.map thickness, (val) ->
        parseInt(val)
      thicknessSum = _.reduce thickness, (a, b) -> a+b

    @$el.css @model.pick 'top', 'left', 'z-index'

    @$el.attr 'class', "#{@elementStyles} #{orientation}"

    if orientation == 'vertical'
      margin = (width - thicknessSum) / 2
      @$el.css height: "#{height}px", margin: "0 #{margin}px"

      if thickness
        @$el.css 'border-width': "0 #{if thickness[2] then thickness[2] else 0}px 0 #{thickness[0]}px"
        @$el.css 'width': if thickness[1] then thickness[1] else 0

    else
      margin = (height - thicknessSum) / 2
      @$el.css width: "#{width}px", margin: "#{margin}px 0"

      if thickness
        @$el.css 'border-width': "#{thickness[0]}px 0 #{if thickness[2] then thickness[2] else 0}px 0"
        @$el.css 'height': if thickness[1] then thickness[1] else 0


  _createPropertiesView: ->
    new Newstime.DividerPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'DividerContentItem'})
