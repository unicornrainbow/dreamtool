
App = Dreamtool

class App.MobileTextEditorView extends App.View

  events:
    'click button.save': 'save'
    'keydown': 'keydown'


  initialize: (options) ->
    @$addClass 'mobile-text-editor-view'

    # { @text } = options

    @$html """
      <textarea></textarea>
      <button class='save'>okay</button>
    """

    @$textarea = @$('textarea')


  setModel: (model) ->
    @model = model

    @text = @model.get('text')

    #unless @text is undefined
    @$textarea.val(@text || '')
    #@$textarea.val(@model.get('text'))

    this

  keydown: (e) ->
    e.stopPropagation() #

  setText: (value) ->
    @text = value
    @$textarea.val(@text)
    this

  save: ->
    @text = @$textarea.val()
    @model.set 'text', @text
    @close()
    #@trigger 'save', this

    # @textAreaContentItem.set 'text', @$textarea.val()

  show: ->
    super and this

  close: ->
    @$hide()
    this

  # slideIn: ->
  #
  # slideOut: ->

  focus: ->
    @$textarea.focus()
    this
