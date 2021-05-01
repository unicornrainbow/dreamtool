App = Dreamtool

# Styles -

# window.flickrAuthSuccess = (flickrUsername)->
#  composer.vent
#   composer.flickrWindow.callback()
#   alert 'Cake!'

class FlickrWindow extends App.View

  className: 'flickr-window'

  events:
    'click .username': 'authorize'

  initialize: (options={}) ->

    @composer = options.composer

    @hide() if options.hidden

    @html """
      <!--h3>Flickr</h3-->
      <button>X</button>
      <div class="photos"></div>
    """

    @$username = @$('a.username')
    @$photos = @$('.photos')
    # @$username.text('')


    @getPhotos (photos) =>
      _.each photos, (photo) =>
        img = document.createElement('img')
        img.src = photo.url
        @$photos.append img


  authorize: ->
    window.open('/flickr/authorize')

  getPhotos: (callback) ->
    $.ajax
      method: 'GET'
      url: '/flickr/photos.json'
      success: callback





App.FlickrWindow = FlickrWindow
