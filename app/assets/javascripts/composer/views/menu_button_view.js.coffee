@Dreamtool ?= {}

class @Dreamtool.MenuButtonView extends Newstime.View

  tagName: 'button'

  initialize: (options={}) ->
    @$el.addClass "menu-button"
    @$el.addClass options["class"]

    @$el.html(options['text'])
    @click = options['click'] if options['click']

    @composer = Newstime.composer

    @listenToOnce Newstime.composer.vent, 'ready', @measureBoundry

    @bindUIEvents()

    @on 'touchout', @touchout
    @on 'touchover', @touchover

    @initializeButton() if @initializeButton?

  measureBoundry: ->
    position = @$el.offset()
    @left   = position.left
    @top    = position.top
    @height = @$el.height()
    @width  = @$el.width()

    @boundry = new Newstime.Boundry _.pick this, 'top', 'left', 'height', 'width'

  mouseover: ->
    if @composer.selectedMenu && @composer.selectedMenu != this
      @open()

    @$el.addClass 'hover'

  mouseout: ->
    @$el.removeClass 'hover'

  mousedown: (e) ->
    @$el.addClass 'pushed'

  mouseup: (e) ->
    @$el.removeClass 'pushed'

  touchstart: (e) ->
    @pressed = true
    @$el.addClass 'pushed'

  touchend: (e) ->
    @$el.removeClass 'pushed'

    if @pressed
      @click()
      @pressed = false

  touchover: (e) ->
    @pressed = true
    @$el.addClass 'pushed'

  touchout: (e) ->
    @pressed = false
    @$el.removeClass 'pushed'

  # press: (e) ->
  #   @pressed = true
