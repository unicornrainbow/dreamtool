#= require ./content_item_view

class @Newstime.TextAreaView extends Newstime.ContentItemView

  contentItemClassName: 'text-area-view'

  @getter 'uiLabel', ->
    "Text"

  initializeContentItem: ->

    @lineHeight = parseInt(Newstime.config.storyTextLineHeight)

    @bind 'resized', @reflow  # Reflow text on resize

    @listenTo @model, 'change:text', @reflow
    @listenTo @model, 'change:rendered_html', @clearNeedsReflow

    @render()

  setElement: (el) ->
    super
    @$el.addClass 'text-area-view'

  render: =>
    unless @needsReflow
      super
      @$el.html @model.get('rendered_html')

    else
      @$el.css @model.pick 'top', 'left'

    @$css 'clip-path', @model.get('shape')

  paste: (e) =>
    # Retreive pasted text. Not cross browser compliant. (Webkit)
    pastedText = e.originalEvent.clipboardData.getData('text/plain')

    @model.set 'text', pastedText

    # Update edit text area window if there is one.
    if @editTextAreaWindow
      @editTextAreaWindow.updateTextFromModel()

    # Now that we have the desired text, need to save this as the text with the
    # story text-content item, should that be our target. Also need to grab and
    # rerender the contents of the pasted text after it has been reflowed.

    #@reflow()

  dblclick: (e) ->
    @showEditTextAreaWindow()

  doubletap: (e) ->
    super
    @showMobileTextEditorWindow()
    # @showEditTextAreaWindow()

  showEditTextAreaWindow: ->
    # Create new text editor window
    @editTextAreaWindow ?= new Newstime.EditTextAreaWindowView
      textAreaContentItem: @model

    panelLayerView = @composer.panelLayerView

    if panelLayerView.hasAttachedPanel(@editTextAreaWindow)
      panelLayerView.bringToFront(@editTextAreaWindow)
      @editTextAreaWindow.show()
    else
      # Add it to the panel view layer
      panelLayerView.attachPanel(@editTextAreaWindow)

  showMobileTextEditorWindow: ->

    #m = @composer.mobileTextEditor
    { mobileTextEditor } = @composer
    mobileTextEditor.setModel(@model)
    #(setModel -> mobileTextEditor @model)
    mobileTextEditor.show().focus()

    #@mobileTextEditor ?= new Dreamtool.MobileTextEditorView
    #  textAreaContentItem: @model
    #  text: @model.get('text')

    #m.setText @model.get('text')
    #@listenTo m, 'save', @mobileTextEditSave
    #(listenTo m 'save' mobileTextEditSave)
    #panelLayerView = @composer.panelLayerView

    # @composer.$body.append m.el
    # @composer.$append(@mobileTextEditorWindow.el)
    #m.focus()

  #mobileTextEditSave: (m) ->
  #  @model.set 'text', m.text
  #  m.close()

  keydown: (e) =>
    switch e.keyCode
      when 49 # 1
        unless e.altKey # Don't clash with zoom 1,2,3
          @model.set('columns', 1)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      when 50 # 2
        unless e.altKey
          @model.set('columns', 2)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      when 51 # 3
        unless e.altKey
          @model.set('columns', 3)
          @reflow()
          e.stopPropagation()
          e.preventDefault()
      else
        super(e)

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    # @ensurePageView()
    height = @pageView.snapBottom(y) - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      height: height

  dragBottomLeft: (x, y) ->
    if @groupView
      x  += @groupView.model.get('left')

    # @ensurePageView()

    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    snapLeft = @pageView.snapLeft(x)
    if snapLeft
      x = snapLeft
      @composer.drawVerticalSnapLine(snapLeft)

    if @groupView
      x  -= @groupView.model.get('left')

    y = @pageView.snapBottom(y)

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: height

  dragBottomRight: (x, y) ->
    if @groupView
      x  += @groupView.model.get('left')

    # @ensurePageView()

    @composer.clearVerticalSnapLines()
    geometry = @getGeometry()
    snapRight = @pageView.snapRight(x)
    y = @pageView.snapBottom(y)

    if snapRight
      @composer.drawVerticalSnapLine(snapRight)
      width = snapRight - geometry.left
    else
      width = x - geometry.left

    if @groupView
      width  -= @groupView.model.get('left')

    height = y - geometry.top
    height = Math.floor(height / @lineHeight) * @lineHeight # Snap to Increments of line height
    @model.set
      width: width
      height: height

  reflow: ->
    @model.reflow()

  clearNeedsReflow: ->
    @needsReflow = false

  _createModel: ->
    @edition.contentItems.add({_type: 'TextAreaContentItem'})

  _createPropertiesView: ->
    new Newstime.TextAreaPropertiesView(target: this, model: @model)
