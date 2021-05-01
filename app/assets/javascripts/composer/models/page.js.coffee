class @Newstime.Page extends Backbone.RelationalModel
  idAttribute: '_id'

  getHTML: (success) ->
    # Example of get html for page
    $.ajax
      url: "#{@url()}.html"
      data:
        composing: true
      success: success
      #success: (data) ->
        #console.log data


  Object.defineProperties @prototype,
    #id:
      #get: -> @get('_id')
      #set: (value) ->
        #@set '_id', value
    top:
      get: -> @get('top')
      set: (value) ->
        @set 'top', value

    left:
      get: -> @get('left')
      set: (value) ->
        @set 'left', value

  contentItems: ->
    @_contentItems ?= @getContentItems()

  getContentItems: ->
    @_contentItems = @get('edition').get('content_items').where(page_id: @get('_id'))

  section: ->
    @_section ?= @getSection()

  getGroups: ->
    @_groups = @get('edition').get('groups').where(page_id: @get('_id'))

  getSection: ->
    @_section = @get('edition').get('sections').findWhere(_id: @get('section_id'))

  collide: (top, left, bottom, right) ->
    bounds = @getBounds()

    # Adapted from http://stackoverflow.com/a/7301852/32384
    ! (bottom < bounds.top ||
       top > bounds.bottom ||
       right < bounds.left ||
       left > bounds.right )

  getBounds: ->
    @pick('top', 'left', 'bottom', 'right')

class @Newstime.PageCollection extends Backbone.Collection
  model: Newstime.Page
  url: ->
    "#{@edition.url()}/pages"
