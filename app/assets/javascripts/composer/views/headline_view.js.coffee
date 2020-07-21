#= require ./content_item_view
class @Newstime.HeadlineView extends Newstime.ContentItemView

  contentItemClassName: 'headline-view'

  inject: ['composer', 'colors']

  initializeContentItem: ->
    @placeholder = "Type Headline" # Text to show when there is no headline
    @fontWeights = Newstime.config.headlineFontWeights

    @listenTo @model, 'change:height change:width change:text change:font_weight change:font_style change:font_family change:text_align', @fitToBorderBox

    # Using invisible textarea as hacky way to get keyboard on mobile.
    @template = """
      <div></div>
      <textarea style='width:100%; height:100%; opacity:0; top:0; left:0; position:absolute;'></textarea>
    """

    @$el.html(@template)

    @$div   = @$('div')
    @$textarea = @$('textarea')

    #@$textarea.keydown(@keydown)
    @$textarea.keyup(@keyup)

    @render()


  setElement: (el) ->
    super
    @$el.html(@template)
    @$div   = @$('div')
    @$textarea = @$('textarea')

    #@$textarea.keydown(@keydown)
    @$textarea.keyup(@keyup)


  render: ->
    @$el.css _.pick @model.attributes, 'top', 'left'
    @$el.css 'z-index': @model.get('z_index')

    @renderMargins()
    @$el.css 'font-family': @model.get('font_family')
    @$el.css 'font-size': @model.get('font_size')
    @$el.css 'font-style': @model.get('font_style')
    @$el.css 'font-weight': @model.get('font_weight')
    @$el.css 'text-align': @model.get('text_align')

    # color = @model.get('color')
    # color
    @$el.css 'color': @model.get('color')


    #@$el.css _.pick @model.changedAttributes()
    @$textarea.val(@model.get('text') || '')
    if !!@model.get('text')
      spanWrapped = _.map @model.get('text'), (char) ->
        if char == '\n'
          char = "<br>"
        "<span>#{char}</span>"

      #spanWrapped.push "<span class='cursor'></span>"
      spanWrapped.splice @model.get('cursorPosition'), 0,
        "<span class='cursor'></span>"

      spanWrapped= spanWrapped.join('')
      @$div.html(spanWrapped)
      @$el.removeClass 'placeholder'
    else
      @$div.text(@placeholder)
      @$el.addClass 'placeholder'

  @getter 'uiLabel', ->
    if @model.get('text')
      "Headline: #{@model.get('text')}"
    else
      "Headline"

  renderMargins: ->
    @$el.css _.pick @model.attributes, 'margin-top', 'margin-right', 'margin-bottom', 'margin-left'

  deselect: ->
    @clearEditMode()
    super()


  keyup: (e) =>
    @model.set 'text', @$textarea.val()
    @render()
    @fitToBorderBox()


  keydown: (e) =>
    if @editMode
      switch e.keyCode
        when 8 # del
          e.stopPropagation()
          e.preventDefault()
          @model.backspace()
        when 27 # ESC
          e.stopPropagation()
          e.preventDefault()
          @clearEditMode()
          @composer.vent.trigger('pages-panel:render')
        when 37 # left arrow
          @moveCursorLeft()
          e.stopPropagation()
          e.preventDefault()
        when 39 # right arrow
          @moveCursorRight()
          e.stopPropagation()
          e.preventDefault()
        else
          unless e.ctrlKey || e.altKey # Skip ctrl and alt
            char = @getEventChar(e)
            if char?
              e.stopPropagation()
              e.preventDefault()
              @model.typeCharacter(char)
    else
      switch e.keyCode
        when 13 # Enter
          @startEditMode()
        when 187 # +
          unless e.altKey
            @increaseFontWeight()
        when 189 # -
          unless e.altKey
            @decreaseFontWeight()
        when 84 # t
          # Trim excess margin from top and bottom
          @trimVerticalMargin()
        when 70 # f
          # Fits the headline to match with with zero margins
          @fit()
        else
          super(e)

  increaseFontWeight: ->
    if @model.get('font_weight')
      # Find current font weight
      fontWeight = parseInt(@model.get('font_weight'))

      index = _.indexOf(@fontWeights, fontWeight)

      fontWeight = @fontWeights[index+1] if index < @fontWeights.length-1

      @model.set('font_weight', fontWeight)
    else
      @model.set('font_weight', @$el.css('font-weight'))

    @fitToBorderBox()

  decreaseFontWeight: ->
    if @model.get('font_weight')
      # Find current font weight
      fontWeight = parseInt(@model.get('font_weight'))

      index = _.indexOf(@fontWeights, fontWeight)

      fontWeight = @fontWeights[index-1] if index > 0

      @model.set('font_weight', fontWeight)
    else
      @model.set('font_weight', @$el.css('font-weight'))

    @fitToBorderBox()

  increaseFont: ->
    if @model.get('font_size')
      @model.set('font_size', parseInt(@model.get('font_size')) + 1 + "px")
    else
      @model.set('font_size', @$headlineEl.css('font-size'))

  decreaseFont: ->
    if @model.get('font_size')
      @model.set('font_size', parseInt(@model.get('font_size')) - 1 + "px")
    else
      @model.set('font_size', @$headlineEl.css('font-size'))

  moveCursorLeft: ->
    if @model.get('cursorPosition')?
      @model.set('cursorPosition', Math.max(@model.get('cursorPosition') - 1, 0))
    else
      @model.set('cursorPosition', @model.get('text').length - 1)


  moveCursorRight: ->
    if @model.get('cursorPosition')?
      @model.set('cursorPosition', Math.min(@model.get('cursorPosition')+1, @model.get('text').length))
    else
      @model.get('cursorPosition', @model.get('text').length)

  dblclick: ->
    @startEditMode()

  tap: (e) ->
    if @editMode
      unless @tapped
        tapped = =>
          # Single tap should clear edit mode.
          @tapped = null
          @clearEditMode()

        @tapped = setTimeout(tapped, 300)
    else
      super

  doubletap: (e) ->
    super
    # How to show keyboard on mobile?
    #@composer.showKeyboard()
    # gee wiz, i wish i had a latching shift key.

    unless @editMode
      @startEditMode()
    # else
    #   @clearEditMode()
    #@composer.showKeyboard()


  startEditMode: ->
    @selectionView.addClass 'edit-mode'
    @addClass 'edit-mode'
    @editMode = true

    @$textarea.focus()


  clearEditMode: ->
    if @editMode
      @editMode = false
      @selectionView.removeClass 'edit-mode'
      @removeClass 'edit-mode'

      @$textarea.blur()


  trimVerticalMargin: ->
    headlineHeight = @$el.height()
    @model.set
      height: headlineHeight
      'margin-top': 0
      'margin-bottom': 0

  # Fits headline to vertical width, vertical margins.
  fit: ->
    # Collect attached items from page that should be move if height is changed.
    attachedItems = @pageView.getAttachedItems(@model)

    headlineHeight = @$el.height()
    height = @model.get('height')

    # Dezoom
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel
      headlineHeight /= zoomLevel

    if headlineHeight < height
      @model.set
        'height': headlineHeight
        'margin-top': 0
        'margin-bottom': 0
    else
      headlineWidth  = @$el.width()

      # Dezoom
      if @composer.zoomLevel
        zoomLevel = @composer.zoomLevel
        headlineWidth  /= zoomLevel

      width = @model.get('width')
      fontSize = parseInt(@$el.css('font-size'))
      fontSize *= width/headlineWidth
      fontSize = Math.round(fontSize)

      @model.set
        'font_size': fontSize + 'px',
        'margin-left': 0
        'margin-right': 0
        'margin-top': 0
        'margin-bottom': 0

      headlineHeight = @$el.height()
      @model.set
        height: headlineHeight


    # Update attached items location.
    #delta = headlineHeight - height
    _.each attachedItems, ([contentItem, offset]) =>
      contentItem.set
        top: @model.get('top') + @model.get('height') + offset.offsetTop

  fitToBorderBox: ->
    # Get the width and height of the headline element.
    headlineWidth  = @$el.width()
    headlineHeight = @$el.height()

    # Dezoom
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel
      headlineWidth  /= zoomLevel
      headlineHeight /= zoomLevel

    width = @model.get('width')
    height = @model.get('height')

    fontSize = parseInt(@$el.css('font-size'))

    fontSize *= if width/height > headlineWidth/headlineHeight
      # Match Height
      height/headlineHeight
    else
      # Match Width
      width/headlineWidth

    fontSize = Math.round(fontSize)
    fontSize = Math.max(fontSize, 1) # 1px min font size.
    @model.set('font_size', fontSize + 'px', silent: true)
    @$el.css 'font-size': @model.get('font_size')


    # Compute and set margins
    headlineWidth  = @$el.width()
    headlineHeight = @$el.height()

    # Dezoom
    if @composer.zoomLevel
      zoomLevel = @composer.zoomLevel
      headlineWidth  /= zoomLevel
      headlineHeight /= zoomLevel

    verticalMargin = (height - headlineHeight)/2
    horizontalMargin = (width - headlineWidth)/2

    margins =
      'margin-top': verticalMargin + 'px'
      'margin-right': horizontalMargin + 'px'
      'margin-bottom': verticalMargin + 'px'
      'margin-left': horizontalMargin + 'px'

    switch @model.get('text_align')
      when 'left'
        margins['margin-left'] = 0
        margins['margin-right'] = horizontalMargin*2 +'px'
      when 'right'
        margins['margin-left'] = horizontalMargin*2 +'px'
        margins['margin-right'] = 0


    @model.set(margins, silent: true)
    @renderMargins()

  _createModel: ->
    # Creates a new model and returns a reference. Used by base class.
    @edition.contentItems.add({_type: 'HeadlineContentItem'})

  _createPropertiesView: ->
    new Newstime.HeadlinePropertiesView(target: this, model: @model)
