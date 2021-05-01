#= require './menu_button_view'

class @Dreamtool.MenuSaveButtonView extends Dreamtool.MenuButtonView

  initializeButton: (options={}) ->
    @$el.html "Save"

  click: (e) ->
    @composer.save()
