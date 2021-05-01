
class @Newstime.HTMLPropertiesView extends Backbone.View
  tagName: 'ul'

  # events:
    # 'change .height-input': 'changeHeight'
    # 'change .width-input': 'changeWidth'

  initialize: (options) ->
    @$el.addClass 'text-area-properties'
    @textAreaView = options.target # Text area view

    @$el.html """
      <li class="property">
        <label>Height</label>
        <span class="field">
          <input class="height-input" style="width:75px"></input></span>
      </li>

      <li class="property">
        <label>Width</label>
        <span class="field">
          <input class="width-input" style="width:75px"></input></span>
      </li>
    """

    @$heightInput = @$('.height-input')
    @$widthInput = @$('.width-input')

    @listenTo @model, 'change', @render

    @render()

  render: ->
    @$heightInput.val(@model.get('height') + 'px')
    @$widthInput.val(@model.get('width') + 'px')
    this

  changeHeight: (e) ->
    @model.set(height: $(e.currentTarget).val())

  changeWidth: (e) ->
    @model.set(width: $(e.currentTarget).val())
