#= require ../views/menu_title_view

class @Newstime.EditionMenuView extends Newstime.MenuTitleView

  initialize: ->
    @title = 'Edition'
    super

  initializeMenu: ->

    @newEditionMenuItem = new Newstime.MenuItemView
      title: 'New Edition'
      click: ->
        window.location = "/editions/new"

    @recentEditionsMenuItem = new Newstime.MenuItemView
      title: 'Recent Editions'
      click: ->
        window.open("/editions", '_blank')

    @settingsMenuItem = new Newstime.MenuItemView
      title: 'Edition Settings'
      click: ->
        #@composer.toggleEditionSettings()
        edition = Newstime.composer.edition
        url = "/editions/#{edition.get('slug') || edition.id}/edit"
        window.open(url, '_blank')

    @printsMenuItem = new Newstime.MenuItemView
      title: 'Prints'
      click: ->
        #@composer.togglePrintsWindow()
        edition = Newstime.composer.edition
        url = "/editions/#{edition.get('slug') || edition.id}/prints"
        window.open(url, '_blank')

    @reflowMenuItem = new Newstime.MenuItemView
      title: 'Reflow Text'
      quickKey: '&#x2325;R'
      click: ->
        @composer.reflow()

    @saveMenuItem = new Newstime.MenuItemView
      title: 'Save'
      quickKey: '&#x2325;S'
      click: ->
        @composer.save()

    @previewMenuItem = new Newstime.MenuItemView
      title: 'Preview'
      quickKey: '&#x2325;P'
      click: ->
        @composer.launchPreview()

    @menuBody.attachMenuItem(@newEditionMenuItem)
    @menuBody.attachMenuItem(@recentEditionsMenuItem)
    @menuBody.attachMenuItem(@settingsMenuItem)
    @menuBody.attachMenuItem(@saveMenuItem)
    @menuBody.attachMenuItem(@printsMenuItem)
    @menuBody.attachMenuItem(@reflowMenuItem)
    @menuBody.attachMenuItem(@previewMenuItem)
