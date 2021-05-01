@Newstime = @Newstime || {}

# TODO: Extract this a content region control perhaps...

class @Newstime.StoryTextControlView extends Backbone.View

  events:
    'click': 'click'

  click: (event) ->
    @toolPalette.setStoryTextControl(this)
    @toolPalette.setPosition(event.y, event.x)
    @toolPalette.show()

  initialize: (options) ->
    @toolPalette = options.toolPalette
