
class @Newstime.DividerPropertiesView extends Backbone.View

  tagName: 'ul'

  events:
   'change .orientation-select': 'changeOrientation'
   'change .thickness': 'changeThickness'

  initialize: ->
    @$el.addClass('divider-properties')

    @$el.html """
      <li class="property">
        <label>Orientation</label>
        <span class="field">
          <select class="orientation-select">
            <option value="horizontal">Horizontal</option>
            <option value="vertical">Vertical</option>
          </select>
        </span>
      </li>
      <li class="property">
        <label>Thickness</label>
        <span class="field">
          <input class="thickness"></input>
        </span>
      </li>
    """

    @$orientationSelect = @$('.orientation-select')
    @$thickness = @$('.thickness')

    @listenTo @model, 'change', @render

    @render()


  render: ->
    @$orientationSelect.val(@model.get('orientation')) if @model.get('orientation')
    @$thickness.val(@model.get('thickness')) if @model.get('thickness')

    this

  changeOrientation: (e) ->
    @model.set('orientation': $(e.currentTarget).val())

  changeThickness: (e) ->
    @model.set('thickness': $(e.currentTarget).val())
