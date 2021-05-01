#= require ../views/menu_title_view

class @Newstime.SectionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Section'
    super

  initializeMenu: ->

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Section Settings'
      quickKey: ''
      click: ->
        #@composer.toggleSectionSettings()
        url = "/editions/#{Newstime.composer.edition.id}/sections/#{Newstime.composer.section.id}/edit"
        window.open(url, '_blank')

    @menuBody.attachMenuItem(@settingsMenuItem)
