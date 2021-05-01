class SectionRenderer

  def initialize(section)
    @section = section
  end

  # Return rendered html
  def render
    # To render the section, we need the edition to do interlink, the layout, to
    # render withing, and the pages, which each get rendered.
    @layout  = @section.layout
    @edition = @section.edition
    @pages   = @section.pages

    page_content = @pages.each_with_index.map do |page, i|
      renderer = PageRenderer.new(page)
      renderer.render(
        'page_number' => i+1,
        'page' => page,
        'edition' => @edition
      )
    end.join

    layout_template = Liquid::Template.parse(@layout.source)
    layout_template.render(
      'yield' => page_content,
      'edition' => @edition
    )
  end

end
