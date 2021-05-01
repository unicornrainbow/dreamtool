@Dreamtool = @Dreamtool || {}

class @Dreamtool.FontLoader
  constructor: ->
    @fontListLoaded = false
    @fontList = null

    @loadFontList()

  loadFontList: ->
    $.ajax '/fonts',

    xhr = new XMLHttpRequest()
    xhr.open 'GET', '/fonts'

    xhr.onreadystatechange = =>
      DONE = 4
      OK = 200

      if xhr.readyState is DONE
        if xhr.status is OK
          @fontList = @parseFontList(xhr.responseText)
          @fontListLoaded = true
          @trigger 'fontListLoaded'

    xhr.send(null)

  parseFontList: (value) ->
    value.split("\n")
