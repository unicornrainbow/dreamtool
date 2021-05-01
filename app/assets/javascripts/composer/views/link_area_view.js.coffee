class @Newstime.LinkAreaView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'link-area-view'

    @listenTo @model, 'change', @render

  render: ->
    @$el.css(_.pick @model, 'top', 'left', 'width', 'height')
