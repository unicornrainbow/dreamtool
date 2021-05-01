#= require ./content_item_view
#
# Description: The video view which appears on the canvas area. Allows videos to
#              be drawn, resized and positioned.
#
class @Newstime.VideoView extends @Newstime.ContentItemView

  contentItemClassName: 'video-view'

  initializeContentItem: ->
    @$caption = @$('.video-caption')
    @listenTo @model, 'change:caption', @captionChanged
    @listenTo @model, 'change:show_caption', @showCaptionChanged
    @listenTo @model, 'change', @render

  @getter 'uiLabel', -> "Video"

  _createPropertiesView: ->
    new Newstime.VideoPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'VideoContentItem'})

  captionChanged: ->
    @$caption.html @model.get('caption')
    @model.set('caption_height', @$caption.height())


  showCaptionChanged: ->
    if @model.get('show_caption')
      @$caption.show()
      @model.set('caption_height', @$caption.height())
    else
      @$caption.hide()
      @model.set('caption_height', 0)

  render: ->
    super
    @$caption.css bottom: -@model.get('caption_height')

  dragBottomRight: (x, y) ->
    aspectRatio = @model.get('aspect_ratio') || 1.777 # (width/height)

    @composer.clearVerticalSnapLines()
    geometry  = @getGeometry()
    snapRight = @pageView.snapRight(x)
    y         = @pageView.snapBottom(y)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width     = x - geometry.left

    height = y - geometry.top

    # Select the largest value with respect to aspect ratio
    #if height * aspectRatio > width
      ## Height is dominant
      #width = height * aspectRatio
    #else
      ## Width is dominant
      #height = width / aspectRatio


    height = width / aspectRatio

    @model.set
      width: width
      height: height
