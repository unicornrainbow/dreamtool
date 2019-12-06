@Newstime = @Newstime || {}

class @Newstime.GroupPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .left-border-field': 'toggleLeftBorder'


  initialize: (options={}) ->

    @groupView  = options.groupView # Group View
    @groupModel = options.model

    @$el.html """
      <li class="property">
        <label>Left Border</label>
        <span class="field">
          <input class='left-border-field' type="checkbox"></input>
        </span>
      </li>
    """

    @$leftBorderField = @$('.left-border-field')


  toggleLeftBorder: ->
    @groupView.toggleLeftBorder()
