#= require ../views/panel_view

class @Newstime.PhotoPickerPanelView extends Newstime.PanelView

  initializePanel: ->
    @$el.addClass 'photo-picker-window-view'
    @model.set
      width: 307
      height: 240
      top: 10
      left: 10

    # Attach photo picker view into body
    @photoPickerView = new Newstime.PhotoPickerView(window: this)
    @$body.html @photoPickerView.el

  # Prompt user to select photo.
  #
  # respondToView - PhotoView to respond to when photo selected.
  selectPhoto: (respondToView) ->
    @respondToView = respondToView
    @show()
