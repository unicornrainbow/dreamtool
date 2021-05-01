class @Newstime.AddPageButton extends Backbone.View

  initialize: (options) ->
    @composer = options.composer
    @$el.html """
      <div class="grid grid12">
        <div class="row">
          <div class="col span12">
            <input class="add-page-btn" type="button" value="Add Page"></input>
          </div>
        </div>
      </div>
    """

    @$row = @$(".row")
    @$button = @$(".add-page-btn")

    @bind 'mouseover', @mouseover
    @bind 'mouseout', @mouseout
    @bind 'mousedown', @mousedown

  top: ->
    @$el.position()['top']

  left: ->
    Math.round(@$row.offset().left)


  width: ->
    parseInt(@$row.css('width'))

  height: ->
    parseInt(@$row.css('height'))

  geometry: ->
    y: @top()
    x: @left()
    width: @width()
    height: @height()

  mouseover: (e) ->
    @hovered = true
    @$button.addClass 'hovered'
    @composer.pushCursor('pointer')

  mouseout: (e) ->
    @hovered = false
    @$button.removeClass 'hovered'
    @composer.popCursor()

  mousedown: (e) ->
    return unless e.button == 0 # Only respond to left button mousedown.
    @composer.addPage()
