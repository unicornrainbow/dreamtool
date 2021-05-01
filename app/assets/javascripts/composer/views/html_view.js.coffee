#= require ./content_item_view

class @Newstime.HTMLView extends Newstime.ContentItemView

  contentItemClassName: 'html-view'

  @getter 'uiLabel', ->
    "HTML"

  initializeContentItem: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'change:HTML change:height change:width', @renderHTML
    @render()
    @renderHTML()

  render: ->
    super
    @$el.css _.pick @model.attributes, 'top', 'left'
    @$el.css 'z-index': @model.get('z_index')

  renderHTML: ->
    html = @model.get('HTML') || ''
    html = html.replace('{{height}}', @model.get('height'))
    html = html.replace('{{width}}',  @model.get('width'))
    @$el.html(html)

  dblclick: (e) ->
    @showHTMLCodeEditor()

  showHTMLCodeEditor: ->
    # Create new text editor window
    @htmlCodeEditorWindow ?= new Newstime.HTMLCodeEditorWindowView
      HTMLContentItem: @model

    panelLayerView = @composer.panelLayerView

    if panelLayerView.hasAttachedPanel(@htmlCodeEditorWindow)
      panelLayerView.bringToFront(@htmlCodeEditorWindow)
      @htmlCodeEditorWindow.show()
    else
      # Add it to the panel view layer
      panelLayerView.attachPanel(@htmlCodeEditorWindow)


  _createPropertiesView: ->
    new Newstime.HTMLPropertiesView(target: this, model: @model).render()

  _createModel: ->
    @edition.contentItems.add({_type: 'HTMLContentItem'})
