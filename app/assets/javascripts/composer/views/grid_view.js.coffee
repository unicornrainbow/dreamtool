@Newstime = @Newstime || {}

class @Newstime.GridView extends Backbone.View

  initialize: (options) ->
    @pageWidth = 1184
    columns = 24
    gutterWidth = 16

    columnWidth = (@pageWidth - (gutterWidth * (columns - 1))) / columns

    @stepWidth = columnWidth + gutterWidth

    ## Compute Left Steps
    firstStep = gutterWidth/2
    columnStep = columnWidth + gutterWidth
    @leftSteps = _(columns).times (i) ->
      columnStep * i + firstStep

    firstStep = columnWidth
    columnStep = columnWidth + gutterWidth
    @rightSteps = _(columns).times (i) ->
      columnStep * i + firstStep + 8

    @rightSnapPoints = _.map @rightSteps, (step) ->
      step # TODO: Has to do with snap, figure out how this extra 8 is sneaking in there. Rearrage.

    @snapDistance = 10

  snapLeft: (value) ->
    closest = Newstime.closest(value , @leftSteps)
    #if Math.abs(closest - value) < @snapDistance then closest else value

  snapRight: (value) ->
    closest = Newstime.closest(value , @rightSteps)
    #if Math.abs(closest - value) < @snapDistance then closest else value

  stepLeft: (value) ->
    closest = Newstime.closest(value - @stepWidth, @leftSteps)

  stepRight: (value) ->
    closest = Newstime.closest(value + @stepWidth, @rightSteps)
