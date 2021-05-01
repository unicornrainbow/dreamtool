# Covers and capture mouse events for relay to interested objects.
class @Newstime.GridLines extends Backbone.View

  initialize: (options) ->
    @$el.addClass "grid-lines"
