App = Dreamtool

_console = $("<div class=\"console\"></div>")
$(document.body).append(_console)

# Temporary logging function for development
log = (msg)->
  _console[0].innerHTML = msg + "</br>" + _console[0].innerHTML

class MobileColorChooserView extends App.View

  events:
    "change input": 'changeColor'
    "touchstart input": 'touchstartInput'
    "touchmove input": 'touchmoveInput'
    "touchend input": 'touchendInput'

  className: 'mobile-color-chooser'

  initialize: ->
    @$el.hide()
    # template = JST['composer/templates/mobile_color_chooser']
    # @html(template(this))
    @html """
<label>Background Color</label>
<input type='range' min=0 max=358 x='hue'></input>
<input type='range' min=0 max=100 x='saturation'></input>
<input type='range' min=0 max=100 x='lightness'></input>
    """

    @$hue = @$("[x=hue]")
    @$saturation = @$("[x=saturation]")
    @$lightness = @$("[x=lightness]")
    @$label = @$('label')

    bgcolor = edition.get('page_color')
    # edition.set('page_color', 'purple')
    #alert bgcolor

  foreground: ->
    @$label.html('Ink Color')
    @k = 'ink_color'
    this

  background: ->
    @$label.html('Page Color')
    @k = 'page_color'
    this

  changeColor: ->
    log("hsl(" + @$hue.val() + ", " + @$saturation.val() + "%, " + @$lightness.val() + "%)")
    # alert edition.get(@k)
    edition.set(@k, "hsl(" + @$hue.val() + ", " + @$saturation.val() + "%, " + @$lightness.val() + "%)")
    # alert @$hue.val()
    # alert 'yes'
    # alert "hsl(" + @$hue.val() + ", 100, 50)"

  touchstartInput: (e) ->
    # log 'you touched' + e.target

   $input = $(e.target)
   @inputWidth =
     $input.width()
   { left: @inputOffsetLeft } =
     $input.offset()

  touchmoveInput: (e) ->
    # log _.keys(e)
    # log Object.keys(e)
    # {left: offsetLeft} = $(e.target).offset()
    # width = $(e.target).width()
    # .left
    # width =

    x = Math.floor(e.touches[0].screenX)
    # log Math.max(0, x - offsetLeft)

    m = Math.max(0, x - @inputOffsetLeft) / @inputWidth
    # log JSON.stringify($(e.target).width())
    m = Math.min(1, m)
    m = Math.floor(m*e.target.max)


    # $(e.target).val(m)
    e.target.value = m
    @changeColor()

    # log $(e.target).offset

    # log e.touches[0].screenX
     # (v,k) ->
      # log k
    # ((k) -> log(k)) for key in e
      # log key
    # log 'you moved' + Object.getPropertyNames(e) #JSON.stringify(e)

  touchendInput: (e) ->
    log 'done' + e.target
    # alert 'you touch my heart'



App.MobileColorChooserView = MobileColorChooserView
