#= require ../views/panel_view
#= require ../views/rollup

class @Newstime.ColorPalatteView extends Dreamtool.Rollup

  _.extend @::events,
    'click .add-color': 'addColor'
    'click .page-color swatch': 'togglePageColorActive'
    'click .ink-color swatch': 'toggleInkColorActive'
    'click .colors li swatch': 'fill'
    'mousedown .colors li': 'grabColor'
    'mouseup': 'mouseUp'
    'mousemove': 'mouseMove'

  initializePanel: (options) ->
    @edition = @composer.edition

    @$el.addClass('newstime-color-palatte')

    # Set default size and position if required.
    @model.set(width: 200, height: 250)
    @setPosition(120, 230) # 🌸

    @$body.html """
      <li class="page-color" style='display:none'><swatch color="#{@composer.edition.get('page_color')}"></swatch>Page Color</li>
      <li class="ink-color"  style='display:none'><swatch color="#{@composer.edition.get('ink_color')}"></swatch>Ink Color</li>

      <ul class="colors"></ul>

      <ul>
        <li class="add-color">Add Color</li>
      </ul>
    """

    swatchMethods =
      setColor: (value) ->
        this.css 'background-color': value

    $.fn.swatch = (methodOrOptions) ->
      this.each ->
        $this = $(this)
        $this.addClass 'swatch'
        $this.css 'background-color': $this.attr('color')

    @$colorList = @$('.colors')
    @$pageColor = @$('.page-color')
    @$pageColorSwatch = $('swatch', @$pageColor).swatch()
    @$inkColor  = @$('.ink-color')

    @$swatches = $('swatch', @$body).swatch()

    @composer.edition.get('colors').forEach (color) =>
      html = $ """
        <li><swatch color="#{color.value}"></swatch>#{color.name}</li>
      """
      swatch = $('swatch', html).swatch()
      html.appendTo @$colorList

    @listenTo @edition, 'change:page_color', @updatePageColor
    @listenTo @edition, 'change:ink_color', @updateInkColor

  updatePageColor: (edition, newValue) ->
    #@$pageColor.swatch('setColor', newValue)
    _newValue = @edition.get('colors').resolve(newValue)
    $('swatch', @$pageColor).css 'background-color': _newValue

  updateInkColor: (e, value) ->
    _value = @edition.get('colors').resolve(value)
    $('swatch', @$inkColor).css 'background-color': _value

  grabColor: (e) ->
    #return false unless e.currentTarget is e.target

    @grabbedColor = $(e.currentTarget)

    colorItems = jQuery('li', @$colorList).toArray()
    @grabbedColorIndex = colorItems.indexOf(e.currentTarget)

    #@grabbedX = e.clientX
    #@grabbedY =

    @grabbedColor.css
      position: 'absolute'
      top: e.clientY - @model.get('top') - 77 + 'px'

  mouseMove: (e) ->
    if @grabbedColor?
      @grabbedColor.css
         top: e.clientY - @model.get('top') - 77 + 'px'

  mouseUp: (e) ->
    if @grabbedColor?
      position = Math.floor((e.clientY - @model.get('top') - 70)/20)

      list = @$colorList[0]
      list.insertBefore(@grabbedColor[0], list.childNodes[position])
      @grabbedColor.css(position: 'relative', top: '')
      @grabbedColor = null


      @composer.edition.set('page_color', list.childNodes[0].innerText)
      @composer.edition.set('ink_color', list.childNodes[1].innerText)
      @composer.edition.set('links_color', list.childNodes[2].innerText)

      # Mirror model changes into Backbone collection.
      # colors = @composer.edition.get('colors')
      # color = colors.models.splice(@grabbedColorIndex, 1)
      # colors.models.splice(position, 0, color[0])

      colorsOrder = _.pluck(list.children, 'innerText')
      setIndex = (color) ->
        color.set 'index', colorsOrder.indexOf(color.name)
      @composer.edition.get('colors').each(setIndex)
      @composer.edition.get('colors').sort()


  fill: (e) ->
    colorValue = $(e.target).attr('color')
    if @pageColorActive
      @composer.edition.set('page_color', colorValue)

    if @inkColorActive
      @composer.edition.set('ink_color', colorValue)


  togglePageColorActive: ->
    @pageColorActive = !@pageColorActive
    if @pageColorActive
      @inkColorActive = false
      @$inkColor.removeClass 'active'

      @$pageColor.addClass 'active'
    else
      @$pageColor.removeClass 'active'

  toggleInkColorActive: ->
    @inkColorActive = !@inkColorActive
    if @inkColorActive
      @pageColorActive = false
      @$pageColor.removeClass 'active'

      @$inkColor.addClass 'active'
    else
      @$inkColor.removeClass 'active'


  addColor: ->
    colorView = new Newstime.ColorView
      respondTo: this
    colorView.attachPanel()
    colorView.show()

  createColor: (name, value) ->
    @composer.edition.get('colors').add
      name: name
      value: value

    html = $ """
      <li><swatch color="#{value}"></swatch>#{name}</li>
    """

    swatch = $('swatch', html).swatch()

    html.appendTo @$colorList
