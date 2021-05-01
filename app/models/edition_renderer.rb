class EditionRenderer

  def initialize(edition)
    @edition = edition
  end

  # Return rendered html
  def render
    template = Liquid::Template.parse(@edition.source)
    template.render('edition' => @edition)
  end

end
