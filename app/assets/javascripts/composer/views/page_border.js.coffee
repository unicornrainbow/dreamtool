# Covers and capture mouse events for relay to interested objects.
class @Newstime.PageBorder extends Backbone.View

  initialize: (options) ->
    @page = options.page
    @model = new Backbone.Model()
    @$el.addClass "page-border"

    @model.bind 'change', @modelChanged, this

  modelChanged: ->
    @$el.css
      top: @getTop()
      left: @getLeft()
      width: @getWidth()
      height: @getHeight()

  getLeft: ->
    @model.get('pageX') + @model.get('pageLeftMargin')

  getTop: ->
    @model.get('pageY') + @model.get('pageTopMargin')

  getWidth: ->
    @model.get('pageWidth') - @model.get('pageLeftMargin') - @model.get('pageRightMargin')

  getHeight: ->
    @model.get('pageHeight') - @model.get('pageTopMargin') - @model.get('pageBottomMargin')
