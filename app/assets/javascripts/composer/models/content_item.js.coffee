#class @Newstime.ContentItem extends Backbone.RelationalModel
@Newstime.ContentItem = Backbone.RelationalModel.extend
  idAttribute: '_id'

  subModelTypeAttribute: '_type'

  subModelTypes:
    'HeadlineContentItem' : 'Newstime.HeadlineContentItem'
    'TextAreaContentItem' : 'Newstime.TextAreaContentItem'
    'PhotoContentItem'    : 'Newstime.PhotoContentItem'
    'VideoContentItem'    : 'Newstime.VideoContentItem'
    'DividerContentItem'  : 'Newstime.DividerContentItem'
    'HTMLContentItem'     : 'Newstime.HTMLContentItem'

  initialize: (attributes) ->
    #@set('cursorPosition', (@get('text') || ' ').length, silent: true)

    @on 'change:page_id', @clearPage

  # Gets page
  getPage: ->
    @_page ?= @get('edition').get('pages').findWhere(_id: @get('page_id'))

  setPage: (page) ->
    @_page = page
    @set 'page_id', page.get('_id')

  getGroup: ->
    if @get('group_id')
      @group ?= @get('edition').get('groups').findWhere(_id: @get('group_id'))
    @group

  clearPage: ->
    @page = null

  getSection: ->
    @getPage().getSection()

  getBoundry: ->
    new Newstime.Boundry(_.pick @attributes, 'top', 'left', 'width', 'height')

  hit: ->
    boundry = @getBoundry()
    boundry.hit.apply(boundry, arguments)



Object.defineProperties @Newstime.ContentItem.prototype,
  top:
    get: -> @get('top')
    set: (value) ->
      @set 'top', value

  left:
    get: -> @get('left')
    set: (value) ->
      @set 'left', value

  #page:
    #get: ->
      #@getPage()
    #set: (value) ->
      #@_page = value
      #@set 'page_id', value.id



class @Newstime.ContentItemCollection extends Backbone.Collection
#@Newstime.ContentItemCollection = Backbone.Collection.extend()
  model: Newstime.ContentItem
  #model: (attrs, options) ->
    #console.log 'hello'

    #switch attrs._type
      #when 'HeadlineContentItem' then new Newstime.HeadlineContentItem(attrs, options)
      ##when 'TextAreaContentItem' then new Newstime.TextAreaView(attrs, options)
      ##when 'PhotoContentItem' then new Newstime.PhotoView(attrs, options)
      ##when 'VideoContentItem' then new Newstime.VideoView(attrs, options)
      ##when 'DividerContentItem' then new Newstime.DividerView(attrs, options)
      #else new Newstime.ContentItem(attrs, options)

    #console.log attrs

    #Newstime.ContentItem

  url: ->
    "#{@edition.url()}/content_items"
