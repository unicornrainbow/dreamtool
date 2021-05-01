
{ sin, cos, sqrt, atan2,
   max, abs, PI } = Math

class Dreamtool.ToolsSpinnerView extends Newstime.View

  initialize: (options) ->
    {@composer, @model} = options

    @buttons = []

    @$el.addClass 'tools-spinner'

    @$el.html """
      <div class="center-dot"></div>
    """

    @setSpnrSize(175)

    @headlineBtn = new TSButtonView
      toolName: 'headline-tool'
      spinner: this
      position: [64, @btnDistance]
      size: @btnSize

    @storyBtn = new TSButtonView
      toolName: 'story-tool'
      spinner: this
      position: [64 - 51.5, @btnDistance],
      size: @btnSize

    @photoBtn = new TSButtonView
      toolName: 'photo-tool'
      spinner: this
      position: [64 - 103, @btnDistance],
      size: @btnSize

    @attachBtn(@headlineBtn)
    @attachBtn(@storyBtn)
    @attachBtn(@photoBtn)

    @$centerDot   =   @$('.center-dot')
    @$headlineBtn  =   @$('.headline-tool')
    @$storyBtn    =   @$('.story-tool')
    @$btns  =  @$('button')


    @$el.css width: @spnrSize, height: @spnrSize


    @$centerDot.css
      width: @centerDotSize
      height: @centerDotSize
      margin: "#{@centerDotMargin}px auto"

    @$btns.css
      width: @btnSize
      height: @btnSize

    @bindUIEvents()

    @model.set
      left:0# -79
      top: 150
      angle: 0

    @listenTo @model, 'change', @render

    @render()

  render: ->
    # Set position
    @$el.css @model.pick('top', 'left')

    _.invoke @buttons, 'render'


  getBtnXY: ([deg, distance], btnSize=0) ->

    deg = deg + @model.get('angle')

    { spnrSize } = this

    x = distance * cos(deg/(180/PI))
    y = distance * sin(deg/(180/PI))

    x = spnrSize/2 + x - btnSize/2
    y = spnrSize/2 - y - btnSize/2

    [x, y]


  setSpnrSize: (value) ->
    @spnrSize = value # spinnerSize

    @btnSize = value * 50/195
    @btnDistance = value * 64/195 # from center
    @centerDotSize = value * 70/195
    @centerDotRadius = @centerDotSize/2
    @centerDotMargin = (value - @centerDotSize)/2


  attachBtn: (button) ->
    @buttons.push(button)
    button.spinner = this
    @$el.append(button.el)

  hit: (x, y) ->
    left = @model.get('left')
    top  = @model.get('top')

    a = x-(left+@spnrSize/2)
    b = y-(top+@spnrSize/2)
    hitRadius = sqrt(a*a+b*b)

    hitRadius <= @spnrSize/2
    # Math.atan2(y, x)
    # true | false

  touchstart: (e) ->
    {x, y} = e.touches[0]

    left = @model.get('left')
    top  = @model.get('top')
    # In terms of the circle
    x -= left+@spnrSize/2
    y -=  top+@spnrSize/2

    # Returns [angle, magnatude]
    touchVector = @getVector(x, y)

    # Are we in the center dot?
    if touchVector[1] <= @centerDotRadius
      @beginDrag(e)
    else
      # button = @hitsButton([x+@spnrSize/2, y+@spnrSize/2])
      # if button
      #   @touchedButton = button
        # _

      # Begin spin
      @speed = 0
      clearInterval(@spinInterval) if @spinInterval

      # Reset angle
      if @model.get('angle') > 360
        @model.set('angle', @model.get('angle')%360)

      @spinning = true
      @spinAngleOffset = touchVector[0] - @model.get('angle')
      @trigger 'tracking', this

      # Must be in the outer ring.
      # find the radius from the center point to the touch center.

  tap: (event) ->
    {x, y} = event.center
    x -= @model.get('left')
    y -= @model.get('top')
    hit = @hitsButton([x, y])  # Does the tap hit a button?
    @selectTool(hit) if hit     # If so, select it.

  hitsButton: (xy) ->
    _.find @buttons, (btn) ->
      btn.hit xy

  selectTool: (button) ->
    # @selectedTool = button.toolName
    # @model.set 'selected-tool', button.toolName
    unless button.toolName == @model.get 'selectedTool'
      @model.set 'selectedTool', button.toolName
    else
      @model.set 'selectedTool', null


  touchmove: (e) ->
    x = e.touches[0].x
    y = e.touches[0].y

    if @moving
      @move(x, y)

    else if @spinning
      left = @model.get('left')
      top  = @model.get('top')
      # In terms of the circle
      x = x-(left+@spnrSize/2)
      y = y-(top+@spnrSize/2)

      touchVector = @getVector(x, y)

      if touchVector[1] <= @spnrSize/2
        angle = touchVector[0] - @spinAngleOffset
        @speed = angle - @model.get('angle')
        if @speed > 180
          @speed = @speed - 360

        else if @speed < -180
          @speed = @speed + 360

        @model.set('angle', angle)
      else
        @letGo()

    else
      if @hit(x, y)
        left = @model.get('left')
        top  = @model.get('top')
        # In terms of the circle
        x = x-(left+@spnrSize/2)
        y = y-(top+@spnrSize/2)

        touchVector = @getVector(x, y)

        if touchVector[1] > @centerDotRadius
          # Begin spin
          @spinning = true
          @spinAngleOffset = touchVector[0] - @model.get('angle')

  letGo: ->
    @spinning = false
    speed = @speed * 2
    return if speed is 0

    angle = @model.get('angle')
    start = Date.now()
    duration = 27 * abs(@speed/50)
    model = @model

    @spinInterval = id = setInterval ->
      t = (Date.now() - start)/(duration * 1000)
      # console.log (speed * duration*10) * (1-(1-t)*(1-t))
      # console.log 1-(1-t)*(1-t)

      # speed
      # scrollTop - (1-t) * speed

      model.set 'angle', angle + (speed * duration*10) * (1-(1-t)*(1-t))

      clearInterval(id) if t > 1
    , 22

  touchend: (e) ->
    if @moving
      @moving = false

    if @spinning
      @letGo()

    @trigger 'tracking-release', this

  move: (x, y) ->
    x -= @leftDragOffset
    y -= @topDragOffset

    x = max(x, -75)
    y = max(y, -75)

    @model.set
      left: x
      top: y

  getVector: (x, y) ->
    # Angle
    angle = -atan2(y, x) * 180/PI
    angle += 360 if angle < 0

    # Distance
    distance = sqrt(x**2+y**2)

    [angle, distance]

  beginDrag: (e) ->
    @moving   = true

    @leftDragOffset = e.touches[0].x - @model.get('left')
    @topDragOffset = e.touches[0].y - @model.get('top')

    @trigger 'tracking', this

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  x: ->
    parseInt(@$el.css('left'))

  y: ->
    parseInt(@$el.css('top'))

  geometry: ->
    x: @x()
    y: @y()
    width: @width()
    height: @height()


class TSButtonView extends Newstime.View

  tagName: 'button'

  initialize: (options) ->
    { @spinner, @size, @position, @toolName } = options

    @$addClass 'tool'
    @$addClass @toolName


  render: ->
    [@x, @y] =  @spinner.getBtnXY(@position, @size)
    @$el.css top: @y, left: @x

    @$toggleClass 'pressed', @toolName == @spinner.model.get('selectedTool')

  hit: ([x, y]) ->
    @x <= x <= @x + @size and
    @y <= y <= @y + @size
