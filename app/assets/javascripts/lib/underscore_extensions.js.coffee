_.mixin
  presence: (value) ->
    if _.isEmpty(value) then null else value
