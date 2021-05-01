#= require ../views/menu_title_view

class @Newstime.PreviewMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Preview'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Settings'
      click: ->
        # TODO: Implement Section > Settings Action

    @menuBody.attachMenuItem(@settingsMenuItem)
