require "markdown_template_handler"

# Add support for rendering .md template and partials.
ActionView::Template.register_template_handler(:md, MarkdownTemplateHandler.new)
#ActionView::Template.register_template_handler(:txt, TextTemplateHandler.new)

$markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)




