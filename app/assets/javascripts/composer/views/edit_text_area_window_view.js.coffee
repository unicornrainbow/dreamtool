#= require ../views/window_view

class @Newstime.EditTextAreaWindowView extends @Newstime.WindowView

  initializeWindow: (options) ->

    _.extend @events,
      'click .bold-btn': 'clickMakeBold'
      'click .italic-btn': 'clickMakeItalic'
      'click .link-btn': 'clickMakeLink'
      'click .update-btn': 'updateText'
      'mousedown .resize-scrub': 'beginResizeDrag'
      'dblclick .title-bar': 'toggleQuietMode'


    @$el.addClass 'edit-text-area-window'

    @textAreaContentItem = options.textAreaContentItem

    @model.set(width: 450, height: 500)

    @setPosition(50, 200)

    @$body.html """
      <div class="buttons-wrap">
        <div class="buttons">
          <button class="update-btn pull-right">↺ Update</button>
          <button class="bold-btn">Bold</button><button class="italic-btn">Italic</button><button class="link-btn">Link</button>
        </div>
      </div>
      <textarea></textarea>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 45


    if @textAreaContentItem.get('text')?
      @$textarea.val(@textAreaContentItem.get('text'))


  renderPanel: ->
    super
    @$textarea.css
      width: @model.get('width')
      height: @model.get('height') - 45

  # Pushes text update to the text area.
  updateText: ->
    @textAreaContentItem.set 'text', @$textarea.val()

  updateTextFromModel: ->
    @$textarea.val(@textAreaContentItem.get('text'))


  beginResizeDrag: (e) ->
      @resizing = true

      # TODO: Fix for mozilla (.clientX/Y)
      # TODO: Drive position from model

      x = e.x || e.clientX
      y = e.y || e.clientY


      @widthMouseOffset = @model.get('left') + @model.get('width') - x
      @heightMouseOffset = @model.get('top') + @model.get('height') - y


      # Engage and begin tracking here.

      @tracking = true
      @trigger 'tracking', this
      @composer.captureLayerView.engage()


  mousemove: (e) ->
    x = e.x || e.clientX
    y = e.y || e.clientY

    y += @composer.panelLayerView.topOffset

    if @tracking
      if @dragging
        @move(x, y)

      if @resizing
        width = x + @widthMouseOffset - @model.get('left')
        height = y + @heightMouseOffset - @model.get('top')
        @resize(width, height)


  mouseup: (e) ->
    if @tracking
      @tracking = false
      @trigger 'tracking-release', this
      @composer.popCursor()
      @mouseover(e)
      @endDrag()

    if @resizing
      @resizing = false


  resize: (width, height) ->
    @model.set(width: width, height: height)

  clickMakeBold: ->
    textrange = @$textarea.textrange('get')

    # Is it already bold?
    if @$textarea.val().substring(textrange.start-2, textrange.start) == '**' && @$textarea.val().substring(textrange.end, textrange.end+2) == '**'

      # If so, unbold.
      @$textarea.textrange('set', textrange.start-2, textrange.length+4)
      @$textarea.textrange('replace', textrange.text)
      @$textarea.textrange('set', textrange.start-2, textrange.length)
    else
      # Bold
      @$textarea.textrange('replace', "**#{textrange.text}**")
      @$textarea.textrange('set', textrange.start + 2, textrange.length)

  clickMakeItalic: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "*#{textrange.text}*")
    @$textarea.textrange('set', textrange.start + 1, textrange.length)

  clickMakeLink: ->
    textrange = @$textarea.textrange('get')
    @$textarea.textrange('replace', "[#{textrange.text}]()")
    @$textarea.textrange('setcursor', textrange.end + 3)


  toggleQuietMode: ->
    if @quietModeOn
      @model.set(@pickings)
      @quietModeOn = false
    else
      @pickings = @model.pick('top', 'left', 'width', 'height')
      width = $(window).width()
      height = $(window).height()
      @model.set
        top: 0
        left: 0
        width: width
        height: height
      @quietModeOn = true

    #...
