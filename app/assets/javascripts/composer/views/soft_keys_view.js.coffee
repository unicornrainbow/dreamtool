App = Dreamtool

class App.SoftKeysView extends App.View

  className: 'soft-keys'

  events:
    'click .esc-key': 'escape'
    'click .group-key': 'group'
    'click .ungroup-key': 'ungroup'
    'click .delete-key': 'delete'
    'click .properties-key': 'properties'

  initialize: (options) ->

    { @composer } = Newstime

    @html """
    """

    @keys = {}

    @createKey('esc')
    @createKey('group')
    @createKey('ungroup')
    @createKey('delete')
    @createKey('properties', '✏︎')


  escape: ->
    @composer.clearSelection()

  group: ->
    @composer.selection.createGroup()

  ungroup: ->
    @composer.selection.contentItemView.ungroup()

  delete: ->
    if confirm "Are you sure you wish to delete this item?"
      @composer.selection.contentItemView.delete()

  properties: ->
    console.log "cheeze cake"
    @composer.toggleProperties()

  # Creates a key
  createKey: (name, text) ->
    $el = $("<button class='#{name}-key'>#{text||name}</button>")
    $el.hide()
    @append $el[0]
    @keys[name] = $el


    # btn = document.createElement('button')
    # btn.classList = key
    # @$el.append()


  showKey: (name) ->

    @keys[name].show()
    @position = @$el.offset()

    # @position = @$el.position()
    # console.log @position

  hideKey: (name) ->
    @keys[name].hide()

  hideKeys: ->
    _.invoke @keys, 'hide'


  hit: (x, y) ->
    # console.log 'soft key', x, y
    return false
