@Newstime = @Newstime || {}

class @Newstime.ContentRegionPropertiesView extends Backbone.View

  events:
    'click .content-region-delete': 'delete'
    'click [data-direction=left]': 'move'
    'click [data-direction=right]': 'move'

  move: (event) ->
    direction = $(event.currentTarget).data('direction')

    $.ajax
      type: "PUT"
      url: "/content_regions/#{@contentRegionId}/move"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
        content_region:
          direction: direction
      complete: =>
        console.log 'move complete'

  initialize: ->
    @palette = new Newstime.PaletteView(title: "Content Region")
    @palette.attach(@$el)

    @palette.bind 'dismiss', =>
      @save()

    @$el.html """
      <div>
      Width:
        <select class="content-region-width">
          <option value="24">Full</option>
          <option value="18">3/4</option>
          <option value="16">2/3</option>
          <option value="15">5/8</option>
          <option value="12">Half</option>
          <option value="9">3/8</option>
          <option value="8">1/3</option>
          <option value="6">1/4</option>
          <option value="4">1/6</option>
          <option value="3">1/8</option>
          <option value="2">1/12</option>
        </select>
      </div>
      <div>
      Move:
        <button data-direction="left">&#8592;</button>
        <button data-direction="right">&#8594;</button>
        <button data-direction="up">&#8593;</button>
        <button data-direction="down">&#8595;</button>
      </div>

      <br>
      <a class="content-region-delete">Delete</a>
    """


    @$el.addClass('content-region-properties')

    @$contentRegionWidth = @$el.find('.content-region-width')

  setPosition: (top, left) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    leftOffset = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    topOffset = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # If greater than a certain distance to the right, subtract the width to
    # counter act.

    if leftOffset + left > 1000
      left = left - @palette.width()

    @palette.setPosition(topOffset + top, leftOffset + left)

  delete: ->
    if confirm 'Click OK to delete content region'
      $.ajax
        type: "DELETE"
        url: "/content_regions/#{@contentRegionId}.json"
        data:
          authenticity_token: Newstime.Composer.authenticityToken
        complete: =>
          # Delete the node and hide palette
          @$contentRegionControl.remove()
          @palette.hide()

  save: ->
    # TODO: If changes to content region, should rerender effected areas
    $.ajax
      type: "PUT"
      url: "/content_regions/#{@contentRegionId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
        content_region:
          column_width: @$contentRegionWidth.val()

  show: ->
    @palette.show()

  setContentRegionControl: (targetControl) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the tool-palette
    rect = targetControl.el.getBoundingClientRect()
    @palette.$el.css(top: rect.top + top, left: rect.right)

    # Initialize Values
    @$contentRegionControl = targetControl.$el
    @contentRegionId = @$contentRegionControl.data('content-region-id')

    # Request values from the backend.
    $.ajax
      type: "GET"
      url: "/content_regions/#{@contentRegionId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
      success: (data) =>
        @$contentRegionWidth.val(data['column_width'])
