class @Newstime.ComplexBoundry

  constructor: (properties) ->
    _.extend(this, properties)
    @boundries = []

  addBoundry: (boundry) ->
    @boundries.push(boundry)

  removeBoundry: (boundry) ->
    i = @boundries.length-1
    while i >= 0
      if @boundries[i] == boundry
        @boundries.splice(i, 1)
      i--

  hit: ->
    args = arguments
    _.any @boundries, (b) -> b.hit.apply(b, args)
