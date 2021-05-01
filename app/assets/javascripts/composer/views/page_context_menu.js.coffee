@Newstime = @Newstime || {}

class @Newstime.PageContextMenu extends Backbone.View

  events:
    'click .delete-page': 'deletePage'

  initialize: (options) ->
    @page = options.page

    @$el.addClass "newstime-context-menu"
    @$el.hide()
    @$el.html """
      <li class="delete-page">Delete Page</li>
    """

  deletePage: ->
    @hide()
    if confirm("Are you sure you would like to delete the page?")
      @page.destroy()

  show: (x, y) ->
    @$el.css left: x, top: y
    @$el.show()

  hide: ->
    @$el.hide()
