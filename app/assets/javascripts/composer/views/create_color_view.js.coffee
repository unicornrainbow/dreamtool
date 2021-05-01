#= require ../views/panel_view
#= require lib/hsl_to_rgb

class @Newstime.ColorView extends Newstime.PanelView

  _.extend @::events,
    'click .create-color': 'createColor'
    'input #hue-slider': 'updateHue'
    'mousemove .color-preview': 'trackColor'
    'mousedown .color-preview': 'mousedownColorPreview'
    'mouseup   .color-preview': 'mouseupColorPreview'

    'mousedown .color-well': 'mousedownColorWell'
    'mousedown .carousel-touch': 'mousedownCarouselTouch'
    'mouseup .carousel-touch': 'mouseupCarouselTouch'
    'mousemove .carousel-touch': 'mousemoveCarouselTouch'

  initializePanel: (options) ->
    @respondTo = options['respondTo']
    @$el.addClass('newstime-color-view')
    @$el.addClass('newstime-properties-panel')

    @model.set width: 250, height: 400

    @setPosition 200, 300

    @$body.html """
      <ul>
      <li class="property">
        <label>Name</label>
        <span class="field">
          <input class="color-name" style="width: 100px"></input>
        </span>
      </li>
      <li class="property">
        <label>Value</label>
        <span class="field">
          <input class="color-value" style="width: 100px"></input>
        </span>
      </li>
      </ul>
      <div class="color-dial">
        <div class="carousel">
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
          <div class="color-well"></div>
        </div>
        <div class="carousel-touch">
        </div>
        <div class="color-preview"></div>
      </div>
      <button class="create-color">Add Color</button>
    """

    @$colorName  = @$('.color-name')
    @$colorValue = @$('.color-value')
    @$colorPreview = @$('.color-preview')
    @$hueSlider    = @$('#hue-slider')

    @$carousel = @$('.carousel')
    @$carouselTouch = @$('.carousel-touch') # For capturing position based on x/y

    @$colorWell1 = @$('.color-well:first-child')
    @$colorWells = @$('.color-well')

    @colorWellCount = @$colorWells.length

    @saturation = 1
    @lightness = .5

    @disperseColorWells()

  disperseColorWells: ->
    circumference = 6.28

    @$colorWells.each (i, el) =>
      angle = circumference/@colorWellCount * i - 3.14

      width = 235
      height = 235

      y = Math.round(105 * Math.sin(angle))
      x = Math.round(105 * Math.cos(angle))

      left = x + width/2
      top = -(y + height/2 - height)

      left -= 12.5
      top -= 12.5

      hue = (Math.round(angle*100)/100 + 3.14)/6.28
      rgb = hslToRgb(hue, @saturation, @lightness)
      hex = @rgbToHex(rgb[0], rgb[1], rgb[2])

      $(el)
        .data(index: i, hue: hue)
        .css
          'top': top
          'left': left
          'background-color': hex


  createColor: ->
    name = @$colorName.val()
    value = @$colorValue.val()
    @respondTo.createColor(name, value)
    @detachPanel()

  updateHue: ->
    @hue = @$hueSlider.val()/100
    rgb = hslToRgb(@hue, @saturation, @lightness)
    @$colorPreview.css 'background-color', "rgb(#{rgb[0]}, #{rgb[1]}, #{rgb[2]});"

    #"hsl(#{hue}, 50, 50)"

  # Attaches panel to composer
  attachPanel: ->
    @composer.attachPanel(this)

  # Detaches panel from composer
  detachPanel: ->
    @hide()
    @composer.detachPanel(this)


  mousedownColorWell: (e) ->
    @$carouselTouch.show()
    @trackingColorWell = true
    @activeColorWellIndex = $(e.target).data('index')

    $target = $(e.target)

    @hue = $target.data('hue')
    rgb = hslToRgb(@hue, @saturation, @lightness)
    hex = @rgbToHex(rgb[0], rgb[1], rgb[2])

    @$colorPreview.css
      'background-color': hex

    @$colorValue.val(hex)


  mousedownCarouselTouch: (e) ->
    @trackingColorWell = true

  mouseupCarouselTouch: (e) ->
    @trackingColorWell = false
    @$carouselTouch.hide()

  mousemoveCarouselTouch: (e) ->
    if @trackingColorWell
      width = 235
      height = 235

      top = e.offsetY
      left = e.offsetX

      x = left - width/2
      y = (height-top) - height/2

      angle = Math.atan2(y, x)


      y = Math.round(105 * Math.sin(angle))
      x = Math.round(105 * Math.cos(angle))

      left = x + width/2
      top = -(y + height/2 - height)

      left -= 12.5
      top -= 12.5

      circumference = 6.28

      @$colorWells.each (i, el) =>
        steps = i - @activeColorWellIndex
        stepValue = circumference/@colorWellCount


        offsetAngle = steps * stepValue + angle
        offsetAngle = Math.round(offsetAngle*100)/100
        if offsetAngle > 3.14
          offsetAngle =  offsetAngle - 6.28


        y = Math.round(105 * Math.sin(offsetAngle))
        x = Math.round(105 * Math.cos(offsetAngle))

        left = x + width/2
        top = -(y + height/2 - height)

        left -= 12.5
        top -= 12.5

        hue = (Math.round(offsetAngle*100)/100 + 3.14)/6.28
        rgb = hslToRgb(hue, @saturation, @lightness)
        hex = @rgbToHex(rgb[0], rgb[1], rgb[2])

        $(el)
          .data(index: i, hue: hue)
          .css
            'top': top
            'left': left
            'background-color': hex


      # Determine hue value

      @hue = (Math.round(angle*100)/100 + 3.14)/6.28
      rgb = hslToRgb(@hue, @saturation, @lightness)
      hex = @rgbToHex(rgb[0], rgb[1], rgb[2])
      @$colorPreview.css 'background-color', hex
      @$colorValue.val(hex)


  trackColor: (e) ->
    if @trackingColor

      @saturation = e.offsetX/175
      @lightness  = 1-(e.offsetY/175)
      rgb = hslToRgb(@hue, @saturation, @lightness)
      hex = @rgbToHex(rgb[0], rgb[1], rgb[2])
      @$colorPreview.css 'background-color', hex
      @$colorValue.val(hex)

      @$colorWells.each (i, el) =>
        hue = $(el).data('hue')
        rgb = hslToRgb(hue, @saturation, @lightness)
        hex = @rgbToHex(rgb[0], rgb[1], rgb[2])

        $(el).css
          'background-color': hex

  mousedownColorPreview: ->
    @trackingColor = true

  mouseupColorPreview: ->
    @trackingColor = false

  componentToHex: (c) ->
    hex = c.toString(16)
    if hex.length == 1 then  "0" + hex else hex

  rgbToHex: (r, g, b) ->
    "\##{@componentToHex(r)}#{@componentToHex(g)}#{@componentToHex(b)}"
