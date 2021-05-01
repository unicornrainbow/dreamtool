class @Newstime.Group extends Backbone.RelationalModel
  idAttribute: '_id'

  initialize: ->
    @items = []
    #@bind 'change', @change
    @bind 'change:_id', @idSet

  Object.defineProperties @prototype,
    top:
      get: -> @get('top')
      set: (value) ->
        @set 'top', value

    left:
      get: -> @get('left')
      set: (value) ->
        @set 'left', value

  change: ->
    #_.each @getContentItems(), (child) =>
      #child.set
        #top: @get('top') + child.get('group_offset_top')
        #left: @get('left') + child.get('group_offset_left')

  idSet: ->
    _.each @items, (item) =>
      item.set 'group_id', @id

  getContentItems: -> # TODO: Should be named getGroupedItems
    @_contentItems ?= @get('edition').get('content_items').where(group_id: @id)

  getGroups: ->
    # Retrive grouped groups
    @_groups ?= @get('edition').get('groups').where(group_id: @id)


  getGroup: ->
    if @get('group_id')
      @group ?= @get('edition').get('groups').findWhere(_id: @get('group_id'))
    @group

  # Return grouped content items and groups as single array.
  getItems: ->
    @_items = _.flatten([@getContentItems(), @getGroups()])

  addItems: (items) ->
    _.each items, @addItem

  addItem: (item) =>
    item.group = this
    unless @isNew()
      item.set 'group_id', @id
    @items.push(item)

  removeItem: (item) =>
    # TODO: Could and probably should be using a collection here...
    index = @items.indexOf(item)
    @contentItemViewsArray.splice(index, 1)

  # Gets page
  getPage: ->
    @_page ?= @get('edition').get('pages').findWhere(_id: @get('page_id'))

  setPage: (page) ->
    @_page = page
    @set 'page_id', page.get('_id')

  # TODO: Shared code with content_item model, should create canvas item root.
  getBoundry: ->
    new Newstime.Boundry(@pick 'top', 'left', 'width', 'height')

  hit: ->
    boundry = @getBoundry()
    boundry.hit.apply(boundry, arguments)

  getOffsetTop: ->
    offset = @get('top')
    if @group
      offset += @group.getOffsetTop()

    offset


  getOffsetLeft: ->
    offset = @get('left')
    if @group
      offset += @group.getOffsetLeft()

    offset


class @Newstime.GroupCollection extends Backbone.Collection
  model: Newstime.Group
  url: ->
    "#{@edition.url()}/groups"
