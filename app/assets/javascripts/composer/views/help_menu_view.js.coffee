#= require ../views/menu_title_view

class @Newstime.HelpMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Help'
    super

  initializeMenu: ->
    @menuBody.model.set(top: 25)
