#= require ./content_item_view

class @Newstime.TextAreaEditorView extends Newstime.ContentItemView

  events:
    'focus textarea': 'focusTextArea'
    'blur textarea': 'blurTextArea'
    'keydown textarea': 'textareaKeydown'

  initialize: (options) ->
    @$el.addClass 'text-area-editor'
    @composer = options.composer

    @bind 'keydown', @keydown

    @$el.html """
      <textarea class="basic-textarea"></textarea>
    """


    @$textarea = @$('textarea')
    @$textarea.elastic()

    # Is the editor visibly displayed?
    @hide()
    @visible = false

  keydown: (e) ->
    switch e.keyCode
      when 27 # ESC
        @hide()

  setModel: (model) ->
    @model = model
    @$textarea.val(@model.get('text'))

  textareaKeydown: (e) ->
    switch e.keyCode
      when 27 # ESC
        e.stopPropagation()
        e.preventDefault()
        @$textarea.blur()
        @composer.focus()

  focusTextArea: ->
    @composer.blur()

  blurTextArea: (e) ->
    @model.set('text', @$textarea.val())
    @model.reflow()
    @composer.focus()

  show: ->
    @visible = true

    unless @focused
      @focused = true
      @composer.pushFocus(this)

    @composer.lockScroll()
    @$el.show()

  hide: ->
    @visible = false

    if @focused
      @focused = false
      @composer.popFocus()

    @$el.hide()
    @composer.unlockScroll()

  hit: (x, y) ->
    return false # Above capture layer, so don't need mouse events from composer.

  mousedown: (e) ->
    @hide()
