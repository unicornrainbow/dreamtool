class @Newstime.MastheadPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .lock': 'changeLock'
    'change .height-input': 'changeHeight'
    'keydown .height-input': 'keydownHeight'

  initialize: (options) ->

    @mastheadView = options.target

    @$el.addClass('page-properties')

    @$el.html """
      <li class="property">
        <label>Lock</label>
        <span class="field">
          <input class='lock' type="checkbox"></input>
        </span>
      </li>

      <li class="property">
        <label>Height</label>
        <span class="field"><input class="height-input"></input></spa>
      </li>
    """

    @$heightInput = @$('.height-input')
    @$lockInput = @$('.lock')

    @listenTo @model, 'change', @render

    @render()


  render: ->
    @$heightInput.val(@model.get('height') + 'px')
    @$lockInput.prop('checked', @model.get('lock'))

  changeLock: ->
    @model.set 'lock', @$lockInput.prop('checked')

  changeHeight: ->
    @mastheadView.setHeight(parseInt(@$heightInput.val()))

  keydownHeight: (e) ->
    switch e.code
      when 'ArrowDown'
        @mastheadView.setHeight(parseInt(@$heightInput.val())-1)
      when 'ArrowUp'
        @mastheadView.setHeight(parseInt(@$heightInput.val())+1)
