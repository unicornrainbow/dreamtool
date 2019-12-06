@Newstime = @Newstime || {}

class @Newstime.EditionPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .ink-color': 'changeInkColor'
    'change .page-color': 'changePageColor'
    'change .links-color': 'changeLinksColor'
    'change .selection-color': 'changeSelectionColor'

  initialize: (options) ->
    @composer = Newstime.composer
    @edition = @composer.edition
    @colors = @edition.get('colors')

    @$el.addClass('page-properties')

    @$el.html """
      <h2>Colors</h2>
      <li class="property">
        <label>Page</label>
        <span class="field">
          <input class="page-color" style="width:150px;"></input>
        </span>
      </li>

      <li class="property"">
        <label>Ink</label>
        <span class="field">
          <input class="ink-color" style="width:150px;"></input>
        </span>
      </li>

      <li class="property">
        <label>Links</label>
        <span class="field">
          <input class="links-color" style="width:150px;"></input>
        </span>
      </li>

      <li class="property">
        <label>Highlight</label>
        <span class="field">
          <input class="selection-color" style="width:150px;"></input>
        </span>
      </li>
    """

    @$pageColor     = @$('.page-color')
    @$inkColor       = @$('.ink-color')
    @$linksColor      = @$('.links-color')
    @$selectionColor = @$('.selection-color')

    @listenTo @model, 'change', @render

    @render()

  changePageColor: ->
    @model.set 'page_color', @$pageColor.val()

    # color = @colors.findWhere(name: @$pageColor.val())

    # if color
    #   @model.set 'page_color', color.get('value')
    # else
    #   @model.set 'page_color', @$pageColor.val()

  changeInkColor: ->
    @model.set 'ink_color', @$inkColor.val()

    # color = @colors.findWhere(name: @$inkColor.val())
    #
    # if color
    #   @model.set 'ink_color', color.get('value')
    # else

  changeLinksColor: ->
    @model.set 'links_color', @$linksColor.val()

  changeSelectionColor: ->
    @model.set 'selection_color', @$selectionColor.val()

  render: ->
    @$pageColor.val @model.get('page_color') if @model.get('page_color')

    # @$pageColor.val typeof @model.get('page_color')
    #
    # # pageColor = @model.get('page_color')
    # #
    # if typeof pageColor is 'string'
    #
    #  = @colors.findWhere(value: @model.get('page_color'))
    #
    # if color
    #
    #   pageColor = @model.get('page_color')
    # if pageColor is @Newstime.Color
    #   @$pageColor.val pageColor.get('name')

    @$inkColor.val @model.get('ink_color') if @model.get('ink_color')
    @$linksColor.val @model.get('links_color') if @model.get('links_color')
    @$selectionValue.val @model.get('selection_color') if @model.get('selection_color')
