$ ->
  $.fn.headlineControl = (toolbar) ->
    this.each (i, el) ->
      new Newstime.HeadlineControlView(el: el, toolbar: toolbar)
