class MarkdownTemplateHandler
  def call(template)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
 
    "#{markdown.render(template.source).inspect}.html_safe;"
    #markdown.render(template.source)
  end
end
