@Newstime = @Newstime || {}

class @Newstime.HeadlinePropertiesView extends Backbone.View
  tagName: 'ul'

  events:
   'change .font-family-select': 'changeFont'
   'change .headline-style': 'changeStyle'
   'change .headline-align': 'changeAlign'
   'change .color': 'changeColor'

  initialize: (options) ->
    @headlineView = options.target

    @$el.addClass('headline-properties')

    @$el.html """
      <li class="property">
        <label>Font</label>
        <span class="field">
          <select class="font-family-select">
            <option value="Exo, sans-serif">Exo</option>
            <option value="EB Garamond, serif">Garamond</option>
            <option value="Sacramento, cursive">Sacramento</option>
            <option value="'Cedarville Cursive', cursive">Cedarville Cursive</option>
            <option value="'Mrs Saint Delafield', cursive">Mrs Saint Delafield</option>
            <option value="'Ruge Boogie', cursive">Ruge Boogie</option>
          </select>
        </span>
      </li>

      <li class="property">
        <label>Style</label>
        <span class="field">
          <select class="headline-style">
            <option value="normal">Normal</option>
            <option value="italic">Italic</option>
          </select>
        </span>
      </li>
      <li class="property">
        <label>Align</label>
        <span class="field">
          <select class="headline-align">
            <option value="left">Left</option>
            <option value="center">Center</option>
            <option value="right">Right</option>
          </select>
        </span>
      </li>

      <li class="property">
        <label>Font Size</label>
        <span class="field">
          <input class="font-size"></input>
        </span>
      </li>
      <li class="property">
        <label>Weight</label>
        <span class="field">
          <input class="font-weight"></input>
        </span>
      </li>
      <li class="property">
        <label>Color</label>
        <span class="field">
          <input class="color" style="width: 100px;"></input>
        </span>
      </li>
    """

    @$fontFamilySelect = @$('.font-family-select')
    @$headlineStyleSelect = @$('.headline-style')
    @$fontSize = @$('.font-size')
    @$align = @$('.headline-align')
    @$fontWeight = @$('.font-weight')
    @$color = @$('.color')

    # @loadFonts()

    @listenTo @model, 'change', @render

    @render()

  render: ->
    @$fontFamilySelect.val(@model.get('font_family')) if @model.get('font_family')
    @$headlineStyleSelect.val(@model.get('font_style'))
    @$fontSize.val(@model.get('font_size'))
    @$align.val(@model.get('text_align'))
    @$fontWeight.val(@model.get('font_weight'))
    @$color.val(@model.get('color'))

  # loadFonts: ->
  #
  #   xhr = new XMLHttpRequest()
  #   xhr.open('GET', '/fonts')
  #   xhr.onreadystatechange = ->
  #     DONE = 4
  #     OK = 200
  #
  #     if xhr.readyState is DONE
  #       if xhr.status is OK
  #          console.log xhr.responseText
  #       else
  #          console.log "Derp: #{xhr.status}"
  #
  #      fontList = xhr.responseText.split(\n)
  #      googleFonts, r = fontList.select(/($1)\/Google$/)
  #      per font in fontList
  #        if font ~= /\/Google/
  #
  #    xhr.send(null)

  changeFont: (e) ->
    @model.set('font_family': $(e.currentTarget).val())
    @headlineView.fitToBorderBox()

  changeStyle: (e) ->
    @model.set('font_style': $(e.currentTarget).val())

  changeAlign: (e) ->
    @model.set('text_align': $(e.currentTarget).val())

  changeColor: (e) ->
    @model.set(color: $(e.currentTarget).val())

  #changeFontSize: (e) ->
