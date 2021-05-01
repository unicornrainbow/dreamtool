class @Newstime.MenuTitleView extends Newstime.View

  tagName: 'span'

  initialize: (options={}) ->
    @$el.addClass "menu-title"

    @composer = Newstime.composer

    @title ?= options.title

    @menuBody = new Newstime.MenuBodyView()

    @$el.html @title

    @menuBody.model.set(top: @composer.menuHeight)

    @listenToOnce Newstime.composer.vent, 'ready', @measureBoundry

    @bindUIEvents()

    @initializeMenu() if @initializeMenu


  measureBoundry: ->
    position = @$el.position()
    @left   = position.left
    @top    = position.top
    @height = @$el.height()
    @width  = @$el.width()

    @boundry = new Newstime.Boundry _.pick this, 'top', 'left', 'height', 'width'

    @menuBody.model.set 'left', @boundry.left

  mouseover: ->
    if @composer.selectedMenu && @composer.selectedMenu != this
      @open()

    @$el.addClass 'hover'

  mouseout: ->
    @$el.removeClass 'hover'

  mousedown: (e) ->
    @toggle()

  toggle: ->
    if @_open then @close() else @open()

  close: ->
    @_open = false
    @$el.removeClass 'open'
    @menuBody.close()
    @composer.selectedMenu = null
    @composer.popFocus()

  open: ->
    if @composer.selectedMenu
      @composer.selectedMenu.close()

    @composer.selectedMenu = this
    @menuBody.open()
    @composer.pushFocus(this)
    @_open = true
    @$el.addClass 'open'

  keydown: (e) =>
    switch e.keyCode
      when 27 # ESC
        @close()

  attachMenuItem: (menuItem) ->
    @menuBody.attachMenuItem(menuItem)
