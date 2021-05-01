@Newstime = @Newstime || {}

Newstime.closest = (goal, ary) ->
  closest = null
  $.each ary, (i, val) ->
    if closest == null || Math.abs(val - goal) < Math.abs(closest - goal)
      closest = val
  closest
