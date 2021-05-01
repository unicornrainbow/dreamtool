#= require ../views/menu_title_view

class @Newstime.ViewMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'View'
    super

  initializeMenu: ->
    @snapMenuItem = new Newstime.MenuItemView
      quickKey: ','
      initializeMenuItem: ->
        @listenTo @composer.vent, 'config:snap:change', =>
          @render()

      renderMenuItem: ->
        if @composer.snapEnabled
          @title = "Snap ✓"
        else
          @title = "Snap"

      click: ->
        @composer.toggleSnap()


    @panelsMenuItem = new Newstime.MenuItemView
      title: 'Hide Panels'
      quickKey: 'P'
      click: ->
        @composer.togglePanelLayer()


    @attachMenuItem(@snapMenuItem)
    @attachMenuItem(@panelsMenuItem)
