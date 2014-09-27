@Newstime = @Newstime || {}

class @Newstime.PageContextMenu extends Backbone.View

  initialize: ->
    @$el.addClass "newstime-context-menu"
    @$el.hide()
    @$el.html """
      <li>Delete Page</li>
    """

  show: (x, y) ->
    @$el.css left: x, top: y
    @$el.show()

  hide: ->
    @$el.hide()
