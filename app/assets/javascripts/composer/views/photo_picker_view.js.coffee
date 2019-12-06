class @Newstime.PhotoPickerView extends Backbone.View

  events:
    'click .photo-thumbnail': 'selectPhoto'

  initialize: (options) ->
    @window = options.window
    @composer = Newstime.composer
    @$el.addClass "photo-picker"
    @$el.html """
      <div class='photos'></div>
      <button onclick="window.open('/flickr/authorize');">Connect Flickr</button>
    """
    @$photos = @$('.photos')
    @loadPhotos()

  loadPhotos: (callme) ->
    # Need to query server for list of photos
    $.ajax
      method: 'GET'
      url: "/flickr/photos.json"
      success: (response) =>
        i = 0
        _.each response, (photo) =>
          @$photos.append """
            <div class="photo-thumbnail"
                 data-photo-id="#{photo.id}"
                 data-edition-relative-url-path="#{photo.url}"
                 style="background-image: url('#{photo.url}')"></div>
          """
          if i == 3
            @$el.append "<br>"
            i = 0
          else
            i++

  selectPhoto: (e) =>
    photoId = $(e.target).data('photo-id')
    url = $(e.target).data('edition-relative-url-path')

    if @composer.selection
      @composer.selection.contentItem.set
        photo_id: photoId
        edition_relative_url_path: url


    #@window.respondToView = null
    #@window.hide()
