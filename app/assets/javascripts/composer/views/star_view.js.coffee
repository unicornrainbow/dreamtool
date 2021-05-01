# class StarView extends @Newstime.CanvasItem
#
#   initialize: ->
#
#     @$el.html """
#       <svg xmlns="http://www.w3.org/2000/svg" version="1.1">
#       </svg>
#     """
#
#     @$svg = @$('svg')
#
#     # Draws a one unit star.
#     @startingPoint 0, 0
#     @addPoint 1, 1
#     @addPoint 1, 2
#     @addPoint 2, 1
#     @addPoint 3, 1
#     @closeShape()
#
#   render: ->
#     _.first(@points)
#     _.rest(@points).map (coords) ->
#       "l " + coords.join(', ')
#     @$svg.html """
#       <path d="">
#     """
#
#   startingPoint: (x, y) ->
#     @points = [[x, y]]
#
#   addPoint: (x, y) ->
#     @points.push([x, y])
#
#   closeShape: ->
#     @closed = true
