#= require composer/models/content_item

class @Newstime.HeadlineContentItem extends Newstime.ContentItem

  typeCharacter: (char) ->

    if @get('text')
      # @set('text', @get('text') + char, silent: true)
      cursorPosition = @get('cursorPosition')
      text = @get('text')
      text = text.substr(0, cursorPosition) + char +
        text.substr(cursorPosition)
      @set('text', text, silent: true)
      @set('cursorPosition', Math.min(@get('cursorPosition') + 1, text.length), silent: true)
      @trigger('change change:text')
    else
      @set('text', char, silent: true)
      @set('cursorPosition', 1, silent: true)
      @trigger('change change:text')


    #if @get('text')
      #@set('text', @get('text').slice(0, @get('cursorPosition'))  + char + @get('text').slice(@get('cursorPosition'), @get('text').length), silent: true)
      #@set('cursorPosition', @get('cursorPosition') + 1, silent: true)
      #@trigger('change')
    #else
      #@set('text', char, silent: true)
      #@trigger('change')

  backspace: ->
    # @set('text', @get('text').slice(0,-1), silent: true)
    cursorPosition = @get('cursorPosition')
    text = @get('text')
    text = text.substr(0, cursorPosition-1) +
      text.substr(cursorPosition)
    @set('text', text, silent: true)
    @set('cursorPosition', Math.max(0, @get('cursorPosition') - 1), silent: true)
    @trigger('change change:text')
