@Newstime = @Newstime || {}


class @Newstime.PhotoPropertiesView extends Backbone.View
  tagName: 'ul'

  events:
    'change .show-caption-field': 'changeShowCaption'
    'change .caption-field': 'changeCaption'
    'change .shape-field': 'changeShape'
    'change .shape-rotate-field': 'changeShapeRotate'
    'keydown .shape-rotate-field': 'keydownShapeRotate'
    'change .height-field': 'changeHeight'
    'change .width-field': 'changeWidth'

  initialize: ->

    @$el.addClass('newstime-photo-properties')

    @$el.html """

      <li class="property">
        <label>Caption</label>
        <span class="field">
          <textarea class="caption-field" style="width: 100px"></textarea>
        </span>
      </li>

      <li class="property">
        <label>Show Cap</label>
        <span class="field">
          <input class='show-caption-field' type="checkbox"></input>
        </span>
      </li>

      <li class="property">
        <label>Effects</label>
        <span class="field">
          <select class='effects-field'>
            <option></option>
            <option>Halftone</option>
          </select>
        </span>
      </li>

      <li class="property">
        <label>Shape</label>
        <span class="field">
          <select class="shape-field">
            <option></option>
            <option value="circle()">Circle</option>
            <option value="ellipse()">Ellispse</option>
            <option value="triangle()">Triangle</option>
          </select>
        </span>
      </li>

      <li class="field">
        <label>Shape Rotate</labeL>
        <span class="field"><input class="shape-rotate-field"></input></span>
      </li>

      <li class="property" style='display: none;'>
        <label>Height</label>
        <span class="field"><input class="height-field"></input></span>
      </li>

      <li class="property" style='display: none;'>
        <label>Width</label>
        <span class="field"><input class="width-field"></input></span>
      </li>

      <li class="property">
        <label>URL</label>
        <span class="field"><input class="url-field"></input></span>
      </li>

    """

    @$captionField = @$('.caption-field')
    @$showCaptionField = @$('.show-caption-field')
    @$effectsField = @$('.effects-field')
    @$shapeField = @$('.shape-field')
    @$shapeRotateField = @$('.shape-rotate-field')
    @$urlField = @$('.url-field')
    @$heightField = @$('.height-field')
    @$widthField = @$('.width-field')

  render: ->
    @$showCaptionField.prop('checked', @model.get('show_caption'))
    @$captionField.val(@model.get('caption') || '')
    @$urlField.val(@model.get('url'))
    @$shapeField.val(@model.get('shape'))
    @$shapeRotateField.val(@model.get('shape-rotate'))
    @$heightField.val(@model.get('height'))
    @$widthField.val(@model.get('width'))

    this

  changeShowCaption: ->
    @model.set 'show_caption', @$showCaptionField.prop('checked')
    @render()

  changeCaption: ->
    @model.set 'caption', @$captionField.val()
    @render()

  changeShape: ->
    unless @model.get('shape-rotate')
      @model.set('shape-rotate', 0)
    @model.set 'shape', @$shapeField.val()
    @render()


  changeShapeRotate: ->
    @model.set 'shape-rotate', @$shapeRotateField.val()
    @render()

  keydownShapeRotate: (e) ->
    if e.key == "ArrowUp"
      r = @$shapeRotateField.val()
      r = parseInt(r)+1
      @model.set('shape-rotate', r)
      @render()
    else if e.key == "ArrowDown"
      @$shapeRotateField.val(@$shapeRotateField.val()*1 - 1)
      @changeShapeRotate()

  changeHeight: ->
    @model.set 'height', @$heightField.val()
    @render()

  changeWidth: ->
    @model.set 'width', @$widthField.val()
    @render()

  changeEffect: ->
    alert 'K3'

#class @Newstime.PhotoPropertiesView extends Backbone.View

  #initialize: ->
    #@palette = new Newstime.PaletteView(title: "Photo")
    #@palette.attach(@$el)

    #@$el.addClass('newstime-photo-properties')

    #@$el.html """
    #"""

  #setPhotoControl: (targetControl) ->
    ## Scroll offset
    #doc = document.documentElement
    #body = document.body
    #left = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    #top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    ## Bind to and position the tool-palette
    #rect = targetControl.el.getBoundingClientRect()
    #@palette.$el.css(top: rect.top + top, left: rect.right)

    ## Initialize Values
    #@$photoControl = targetControl.$el
    #@photoId = @$photoControl.data('photo-id')

    ## Request values from the backend.
    ##$.ajax
      ##type: "GET"
      ##url: "/photos/#{@photoId}.json"
      ##data:
        ##authenticity_token: Newstime.Composer.authenticityToken
      ##success: (data) =>
        ##@$contentRegionWidth.val(data['column_width'])

  ## TODO: Generalize to floating tool pallete abstraction
  #setPosition: (top, left) ->
    ## Scroll offset
    #doc = document.documentElement
    #body = document.body
    #leftOffset = (doc && doc.scrollLeft || body && body.scrollLeft || 0)
    #topOffset = (doc && doc.scrollTop  || body && body.scrollTop  || 0)

    ## If greater than a certain distance to the right, subtract the width to
    ## counter act.

    #if leftOffset + left > 1000
      #left = left - @palette.width()

    #@palette.setPosition(topOffset + top, leftOffset + left)

  #show: ->
    #@palette.show()
