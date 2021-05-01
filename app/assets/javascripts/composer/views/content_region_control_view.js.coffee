@Newstime = @Newstime || {}

class @Newstime.ContentRegionControlView extends Backbone.View

  events:
    'click .content-region-settings': 'showSettings'

  initialize: (options) ->
    @propertiesView = options.propertiesView

    @$el.addClass 'content-region-control-view'

    @$toolbar = $ """
      <div class="content-region-toolbar">
        <a class="content-region-settings"><i class="fa fa-gear"></i></a>
      </div>
    """
    @$toolbar.prependTo(@$el)

  showSettings: (event) ->
    @propertiesView.setContentRegionControl(this)
    @propertiesView.setPosition(event.y, event.x)
    @propertiesView.show()
