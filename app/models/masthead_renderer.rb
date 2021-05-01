class MastheadRenderer

  def initialize(masthead)
    @masthead = masthead
  end

  # Return rendered html
  def render
    template = Liquid::Template.parse(@masthead.source)
    template.render('masthead' => @masthead)
  end

end
