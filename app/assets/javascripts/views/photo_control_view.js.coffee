@Newstime = @Newstime || {}

# TODO: Extract this a content region control perhaps...

class @Newstime.PhotoControlView extends Backbone.View

  events:
    'click': 'click'

  click: (event) ->
    # TODO: Needs to be generalized.
    @propertiesView.setPhotoControl(this)
    @propertiesView.setPosition(event.y, event.x)
    @propertiesView.show()

  initialize: (options) ->
    @propertiesView = options.propertiesView
