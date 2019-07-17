#= require ./content_item_view
#
# Description: The photo view which appears on the canvas area. Allows photos to
#              be drawn, resized and positioned.
#
class @Newstime.PhotoView extends Newstime.ContentItemView

  contentItemClassName: 'photo-view'

  initializeContentItem: ->
    # Attempting to capture elements. Probably to return empty objects, because
    # the template has not been rendered yet.
    @$img = @$el.find('img')
    @$caption = @$('.photo-caption')

    # Ensure caption height has a value
    unless @model.get('caption_height')
      @model.set('caption_height', 0)

    # Element for view is reset when the ContentItemView returns from a server
    # render. The set-element event is triggered. We handle it here to get
    # references to the img and photo-caption elements.
    @bind 'set-element', =>
      @$img = @$el.find('img')
      @$caption = @$('.photo-caption')

    @listenTo @model, 'change:photo_id', @photoChanged
    @listenTo @model, 'change:caption', @captionChanged
    @listenTo @model, 'change:show_caption', @showCaptionChanged
    @listenTo @model, 'change', @render

    @render()

  @getter 'uiLabel', -> "Photo"

  photoChanged: ->
    @$img.attr "src", @model.get('edition_relative_url_path')

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

    photoSize =  @model.pick('height', 'width')
    photoSize.height -=  @model.get('caption_height')

    if @model.get('shape') == 'triangle()'
      rotate = @model.get('shape-rotate')
      rotate %= 120
      s = rotate/30%1* 50
      switch
        when rotate < 30
          #clipPath = 'polygon(50% 0, 100% 100%, 0 100%)'
          a = 50 + s
          b = 100 - s
          clipPath = "polygon(#{a}% 0, 100% 100%, 0 #{b}%)"
        when rotate < 60
          #clipPath = 'polygon(100% 0, 100% 100%, 0 50%)'
          a = 100 - s
          b = 50 - s
          clipPath = "polygon(100% 0, #{a}% 100%, 0 #{b}%)"
        when rotate < 90
          #clipPath = 'polygon(100% 0%, 50% 100%, 0 0%)'
          clipPath = "polygon(100% #{0+s}%, #{50-s}% 100%, 0 0%)"
        when rotate < 120
          #clipPath = 'polygon(100% 50%, 0% 100%, 0% 0)'
          # clipPath = "polygon(100% #{50+s}%, #{0+s}% 100%, 0% 0)"
          clipPath = "polygon(100% #{50+s}%, 0% 100%, #{0+s}% 0)"

      @$img.css 'clip-path', clipPath
    else
      @$img.css 'clip-path', @model.get('shape')

    @$img.css photoSize


  dblclick: (e) =>
    @composer.photoPicker.selectPhoto(this)


  # Event handler for browser paste event.
  #
  # Retrieves data from clipboard, uploads it to the server, and updates the
  # photo in the view.
  paste: (e) =>
    item = e.originalEvent.clipboardData.items[0]
    if item && item.type.indexOf "image" != -1
      # Get image file from clipboard item.
      attachment = item.getAsFile()

      # Construct form data and upload the file.
      form = new FormData()
      file_name = Math.random().toString(36).substring(7)
      form.append("photo[attachment]", attachment, file_name)
      form.append("photo[name]", file_name)

      $.ajax
        url: '/photos'
        type: 'POST'
        data: form
        cache: false
        dataType: 'json'
        processData: false
        contentType: false
        success: (data, textStatus, jqXHR) =>
          @model.set
            photo_id: data['_id']
            edition_relative_url_path: data['edition_relative_url_path']

        #error: (jqXHR, textStatus, errorThrown) ->
          #console.log('ERRORS: ' + textStatus)

  _createPropertiesView: ->
    new Newstime.PhotoPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'PhotoContentItem'})
