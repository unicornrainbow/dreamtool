@Newstime = @Newstime || {}

class @Newstime.HeadlineControlView extends Backbone.View

  events:
    'click': 'click'

  click: ->
    if @toolbar.headlineControl != this
      @toolbar.setHeadlineControl(this)
    else
      @changeText()

  initialize: (options) ->
    @toolbar = options.toolbar

  changeText: ->
    text = prompt("Headline Text", @$el.text())
    text = text.replace('\\n', "<br>")
    @$el.html(text) if text
