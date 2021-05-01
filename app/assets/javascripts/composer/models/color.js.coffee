class @Newstime.Color extends Backbone.RelationalModel
  idAttribute: '_id'

  Object.defineProperties @prototype,
    name:
      get: -> @get('name')
      set: (value) ->
        @set 'name', value

    value:
      get: -> @get('value')
      set: (value) ->
        @set 'value', value

  initialize: ->
    @setKey()

  setKey: ->
    @set 'key', @name.replace(/ /g, '').toLowerCase()


class @Newstime.ColorCollection extends Backbone.Collection
  model: Newstime.Color
  comparator: 'index'
  url: ->
    "#{@edition.url}/colors"

  # Resolves value of color.
  resolve: (value) ->
    color = @findWhere(key: value.replace(/ /g, '').toLowerCase())
    if color
      color.get('value')
    else
      value

  setKeys: ->
    @invoke 'setKey'
