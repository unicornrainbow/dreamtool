@Newstime = @Newstime || {}

class @Newstime.StoryPropertiesView extends Backbone.View

  events:
    'click .story-delete': 'delete'
    'click .story-reflow': 'reflow'

  initialize: ->
    @palette = new Newstime.PaletteView(title: "Story")
    @palette.attach(@$el)

    @palette.bind 'dismiss', =>
      @save()

    @$el.addClass('newstime-story-properties')

    @$el.html """
      <div>
      Column:
        <select class="story-content-item-columns">
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="4">4</option>
          <option value="5">5</option>
        </select>
      </div>
      <br>
      Height:
      <input class="nt-control story-content-item-height"></input>
      <br>
      <a class="story-link" href="">Story</a>
      <br>
      <a class="story-reflow" href="">Reflow</a>
      <br>
      <a class="story-delete" href="">Delete</a>
    """

    @$columnsSelect = @$el.find('.story-content-item-columns')
    @$heightInput = @$el.find('.story-content-item-height')
    @$storkLink = @$el.find('.story-link')

  delete: ->
    if confirm 'Click OK to delete story'
      $.ajax
        type: "DELETE"
        url: "/content_items/#{@storyTextId}.json"
        data:
          authenticity_token: Newstime.Composer.authenticityToken
        complete: =>
          # Delete the node and hide palette
          @$storyText.remove()
          @palette.hide()


  # Reflows the story
  reflow: ->
    $.ajax
      type: "PUT"
      url: "/content_items/#{@storyTextId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
      complete: =>
        location.reload()

  save: ->
    $.ajax
      type: "PUT"
      url: "/content_items/#{@storyTextId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
        content_item:
          columns: @$columnsSelect.val()
          height: @$heightInput.val()

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

  show: ->
    @palette.show()

  setStoryTextControl: (targetControl) ->
    # Scroll offset
    doc = document.documentElement
    body = document.body
    left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    # Bind to and position the tool-palette
    rect = targetControl.el.getBoundingClientRect()
    #@setPosition(rect.top + top, rect.right)

    # Initialize Values
    @$storyText = targetControl.$el
    @storyTextId = @$storyText.data('story-text-id')

    # Request values from the backend.
    $.ajax
      type: "GET"
      url: "/content_items/#{@storyTextId}.json"
      data:
        authenticity_token: Newstime.Composer.authenticityToken
      success: (data) =>
        @$columnsSelect.val(data['columns'])
        @$heightInput.val(data['height'])
        @$storkLink.text(data['story']['name'])
        @$storkLink.attr(href: data['story']['url'])
