class PageRenderer

  def initialize(page)
    @page = page
  end

  # Return rendered html
  def render(params={})
    result = ''

    page_template = Liquid::Template.parse(@page.source)
    result = page_template.render(params)

    if @page.layout
      layout = @page.layout
      layout_template = Liquid::Template.parse(layout.source)
      result = layout_template.render(params.merge('yield' => result))
    else
      result
    end
  end

end
