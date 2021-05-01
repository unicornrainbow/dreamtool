#= require ../views/window_view

class @Newstime.HTMLCodeEditorWindowView extends @Newstime.WindowView

  initializeWindow: (options) ->

    _.extend @events,
      'click .update-btn': 'updateCode'
      'mousedown .resize-scrub': 'beginResizeDrag'

    @$el.addClass 'html-code-editor-window'


    @HTMLContentItem = options.HTMLContentItem

    @model.set(width: 450, height: 500)

    @setPosition(50, 200)

    @$body.html """
      <div class="buttons">
        <button>Push Me</button>
        <button class="update-btn pull-right">↺ Update</button>
      </div>
      <textarea></textarea>
    """

    @$textarea = @$('textarea')

    @$textarea.css
      width: 450
      height: 500 - 45

    if @HTMLContentItem.get('HTML')?
      @$textarea.val(@HTMLContentItem.get('HTML'))

  renderPanel: ->
    super
    @$textarea.css
      width: @model.get('width')
      height: @model.get('height') - 45


  updateCode: ->
    @HTMLContentItem.set 'HTML', @$textarea.val()

  updateTextFromModel: ->
    @$textarea.val(@HTMLContentItem.get('HTML'))

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
