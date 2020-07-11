#= require composer/models/content_item

class @Newstime.TextAreaContentItem extends Newstime.ContentItem

  calculateLineWidths : ->
    # Returns an array of line widths to be used for type setting.
    @model.get('shape')

    [@model.get('width')]


  reflow: (options={}) ->
    callDepth = options.callDepth || 0

    # Decide if we are part of a continuation.
    storyTitle = @get('story_title') # (Serves as the anchor reference on the page, simply need section and page reference)

    if storyTitle?

      # Get all content items with matching story title
      edition = @get('edition')
      contentItems = edition.get('content_items')
      storyContentItems = contentItems.where('story_title': storyTitle)

      # Sort content items based on section, page, y, x
      storyContentItems = storyContentItems.sort (a, b) ->
        if a.getSection().get('sequence') != b.getSection().get('sequence')
          a.getSection().get('sequence') - b.getSection().get('sequence')
        else if a.getPage().get('number') != b.getPage().get('number')
          a.getPage().get('number') - b.getPage().get('number')
        else if a.get('top') != b.get('top')
          a.get('top') - b.get('top')
        else
          a.get('left') - b.get('left')

      index = _.indexOf storyContentItems, this

      # TODO: Always start with first in the chain...
      if callDepth == 0
        # First call: Ensure starting with first text area in order.
        # Call reflow on first with callDepth 1 to skip this...

        return storyContentItems[0].reflow(callDepth: callDepth + 1)

      if index > 0
        previousContentItem = storyContentItems[index-1]
        leading_page = previousContentItem.getPage()
        leading_section = previousContentItem.getSection()
        @set
          lead_text_area_id: previousContentItem.get('_id')
          precedent_text: "<strong>#{@get('story_title')}</strong>, from Page #{leading_page.get('page_ref')}"
          #precedent_path: "#{leading_section.get('path')}#page-#{leading_page.get('number')}"
          #precedent_path: "#{leading_section.get('path')}##{leading_section.get('letter')}#{leading_page.get('number')}/#{storyTitle}"
          precedent_path: "#{leading_section.get('path')}##{leading_page.get('page_ref')}/#{storyTitle}"

      else
        @set
          lead_text_area_id: null
          precedent_text: null
          precedent_path: null


      if index+1 < storyContentItems.length
        nextContentItem = storyContentItems[index+1]
        trailing_page = nextContentItem.getPage()
        trailing_section = nextContentItem.getSection()

        @set
          follow_text_area_id: nextContentItem.get('_id')
          continuation_text: "See <strong>#{@get('story_title')}</strong> on Page #{trailing_page.get('page_ref')}"
          #continuation_path: "#{trailing_section.get('path')}#page-#{trailing_page.get('number')}"
          #continuation_path: "#{trailing_section.get('path')}##{trailing_section.get('letter')}#{trailing_page.get('number')}/#{storyTitle}"
          continuation_path: "#{trailing_section.get('path')}##{trailing_page.get('page_ref')}/#{storyTitle}"

      else
        @set
          follow_text_area_id: null
          continuation_text: null
          continuation_path: null


      if previousContentItem
        @set 'overflow_input_text', previousContentItem.get('overrun_html')

    $.ajax
      type: 'POST'
      url: "#{@get('edition').url()}/render_text_area.json"
      contentType: 'application/json'
      dataType: 'json'
      data:
        JSON.stringify
          composing: true
          content_item: @toJSON()
      success: (response) =>
        @set _.pick(response, 'rendered_html', 'overrun_html')

        # Trigger reflow of next content item
        nextContentItem.reflow(callDepth: callDepth+1) if nextContentItem
      error: (response) ->
        alert response.statusText

  initialTextArea: ->
    # Decide if we are part of a continuation.
    storyTitle = @get('story_title')

    # Get all content items with matching story title
    edition = @get('edition')
    contentItems = edition.get('content_items')
    storyContentItems = contentItems.where('story_title': storyTitle)

    # Sort content items based on section, page, y, x
    storyContentItems = storyContentItems.sort (a, b) ->
      if a.getSection().get('sequence') != b.getSection().get('sequence')
        a.getSection().get('sequence') - b.getSection().get('sequence')
      else if a.getPage().get('number') != b.getPage().get('number')
        a.getPage().get('number') - b.getPage().get('number')
      else if a.get('top') != b.get('top')
        a.get('top') - b.get('top')
      else
        a.get('left') - b.get('left')

    storyContentItems[0]
