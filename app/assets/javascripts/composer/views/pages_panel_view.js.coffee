#= require ../views/panel_view
#
class @Newstime.PagesPanelView extends @Newstime.PanelView

  _.extend @::events,
    'click .pages-panel-page'  : 'clickPagesPanelPage'
    'click .pages-panel-item'  : 'clickPagesPanelItem'

  initializePanel: ->
    @$el.addClass 'pages-panel'

    @viewOptions = {}

    @model.set(width: 200, height: 200)

    # Render each page
    @template = _.template """
      <ol>
      <% _.each(pages, function (page) { %>
        <% if (page.options.collapsed != true) { %>
          <li class="pages-panel-page <%= page.selected ? "selected" : "" %>" data-id="<%= page.cid %>"><%= page.name %></li>
          <% if (page.items.length > 0) { %>
            <ol>
              <% _.each(page.items, function (item) { %>
                <li class="pages-panel-item indent-level-1 <%= item.selected ? "selected" : "" %>"
                    data-id="<%= item.cid %>"><%= item.name %></li>
              <% }); %>
            </ol>
          <% } %>
        <% } else { %>
          <li class="pages-panel-page collasped <%= page.selected ? "selected" : "" %>" data-id="<%= page.cid %>"><%= page.name %></li>
        <% } %>
      <% }); %>
      </ol>
    """

    @listenTo @composer.vent, 'page:canvas-items-reorder', -> @renderPanel()
    @listenTo @composer.vent, 'pages-panel:render', -> @renderPanel()

    #setInterval _.bind(@renderPanel, this), 200
    #@listenTo @composer.canvas, 'render', @renderPanel

  clickPagesPanelPage: (e) ->
    if e.offsetX < 30
      # Less the 30 pixels in, toggle collaspe
      $target = $(e.target)
      viewID = $target.data('id')
      @viewOptions[viewID] ?= {}
      @viewOptions[viewID].collapsed = !@viewOptions[viewID].collapsed
      @renderPanel()
    else
      # More then 30 pixel in, select page
      $target = $(e.target)
      viewID = $target.data('id')
      view = @composer.canvas.findViewByCID(viewID)
      if view instanceof Newstime.CanvasItemView
        @composer.select(view)
      else if view instanceof Newstime.PageView
        @composer.selectPage(view)

      @renderPanel()

  clickPagesPanelItem: (e) ->
    $target = $(e.target)
    viewID = $target.data('id')

    # Find view by cid
    view = @composer.canvas.findViewByCID(viewID)

    if e.shiftKey
      @composer.addToSelection(view)
    else
      @composer.select(view)

  clickPagesPanelGroup: (e) ->
    if e.offsetX < 30
      # Less the 30 pixels in, toggle collaspe
      $target = $(e.target)
      viewID = $target.data('id')
      @viewOptions[viewID] ?= {}
      @viewOptions[viewID].collapsed = !@viewOptions[viewID].collapsed
      @renderPanel()
    else
      # More then 30 pixel in, select group
      $target = $(e.target)
      viewID = $target.data('id')

      # Find view by cid
      view = @composer.canvas.findViewByCID(viewID)

      if e.shiftKey
        @composer.addToSelection(view)
      else
        @composer.select(view)

  renderPanel: =>
    pageViews = @composer.canvas.pageViewsArray
    pages = _.map pageViews, (view) =>
      page = {}
      page.name = view.uiLabel
      page.cid = view.cid
      page.options = @viewOptions[view.cid] || {}
      page.selected = (view == @composer.selection)
      page.items = _.map view.contentItemViewsArray, (itemView) =>
        item = {}
        item.name = itemView.uiLabel
        item.cid  = itemView.cid
        item.options = @viewOptions[itemView.cid] || {}
        item.selected = itemView.selected
        return item

      page

    # Note: Need to pass the groupTemplate in as a variable to get access to it.
    vars = _.extend(@model.toJSON(), pages: pages)
    html = @template(vars)
    @$body.html(html)
