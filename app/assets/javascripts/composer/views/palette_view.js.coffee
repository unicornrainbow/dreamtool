@Newstime = @Newstime || {}

class @Newstime.PaletteView extends Backbone.View

  events:
   'mousedown .title-bar': 'beginDrag'
   'mouseup .title-bar': 'endDrag'
   'click .dismiss': 'dismiss'

  initialize: (options) ->
    @$el.hide()
    @$el.addClass('newstime-palette-view')

    @$el.html """
      <div class="title-bar">
        #{options.title}
        <span class="dismiss"></span>
      </div>
      <div class="palette-body">
      </div>
    """

    # Select Elements
    @$body = @$el.find('.palette-body')
    @$titleBar = @$el.find('.title-bar')

    # Attach to dom
    $('body').append(@el)

  dismiss: ->
    @trigger 'dismiss'
    @hide()

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()

  moveHandeler: (e) =>
    @$el.css('top', event.pageY + @topMouseOffset)
    @$el.css('left', event.pageX + @leftMouseOffset)

  beginDrag: (e) ->
    @$titleBar.addClass('grabbing')

    # Calulate offsets
    @topMouseOffset = parseInt(@$el.css('top')) - event.pageY
    @leftMouseOffset = parseInt(@$el.css('left')) - event.pageX

    $(document).bind('mousemove', @moveHandeler)

  endDrag: (e) ->
    @$titleBar.removeClass('grabbing')
    $(document).unbind('mousemove', @moveHandeler)

  # Attachs html or element to body of palette
  attach: (html) ->
    @$body.html(html)

  setPosition: (top, left) ->
    @$el.css(top: top, left: left)

  width: ->
    parseInt(@$el.css('width'))
