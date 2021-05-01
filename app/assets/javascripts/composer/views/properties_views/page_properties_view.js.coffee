@Newstime = @Newstime || {}

class @Newstime.PagePropertiesView extends Backbone.View
  tagName: 'ul'


  initialize: (options) ->

    @$el.addClass('page-properties')

    @$el.html """
      <li class="property">
        <label>Number</label>
        <span class="field">
          <input class="page-number"></input>
        </span>
      </li>
    """

    @$pageNumber = @$('.page-number')

    @listenTo @model, 'change', @render

    @render()


  render: ->
    @$pageNumber.val @model.get('number') if @model.get('number')
