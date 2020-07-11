# Simple typesetter for text area content items
require "net/http"
require "uri"

class TextAreaTypesetter
  attr_reader :text_area

  def initialize(text_area, layout_module, lead_text_area=nil, follow_text_area=nil)
    @text_area = text_area
    @layout_module = layout_module

    @lead_text_area = lead_text_area
    @follow_text_area = follow_text_area
  end

  # Typesets content items.
  def typeset!(force=false)
    # Override text with overflow_input_text if provided.
    text = text_area.overflow_input_text.presence || text_area.text

    html = $markdown.render(text)
    doc = Nokogiri::HTML(html)
    elements = doc.css("body > p")
    html = elements.to_html

    result = ""
    height             = text_area.height
    text_column_width  = text_area.text_column_width
    column_count       = text_area.columns
    include_by_line    = text_area.show_by_line
    offset_leader      = text_area.offset_leader.to_i

    include_precedent_link = !!@text_area.precedent_text
    include_continuation = !!@text_area.continuation_text

    column_count.times do |column_index|
      render_by_line        = include_by_line && column_index.zero?
      render_continuation   = include_continuation && column_index + 1 == column_count
      render_precedent_link = include_precedent_link && column_index.zero?
      render_offset_leader  = offset_leader > 0 && column_index.zero?

      if render_continuation
        #trailing_page = @follow_text_area.page
        #trailing_section = trailing_page.section
        continuation_text = @text_area.continuation_text
        continuation_path = @text_area.continuation_path
        #continuation_text = "Continued on Page #{trailing_page.page_ref}"
        #continuation_path = "#{trailing_section.path}#page-#{trailing_page.number}"
      end

      if render_precedent_link
        # stiched could also work
        #leading_page = @lead_text_area.page
        #leading_section = leading_page.section
        precedent_text = @text_area.precedent_text
        precedent_path = @text_area.precedent_path
        #precedent_text = "Continued from Page #{leading_page.page_ref}"
        #precedent_path = "#{leading_section.path}#page-#{leading_page.number}"
      end


      # Has text overrun, should be determined on the
      is_last_column = column_index + 1 == column_count
      has_text_overrun = html && !render_continuation && is_last_column
      has_text_overrun = false # Disable text overrun for the moment

      column_height = height
      column_height = render_by_line ? column_height - 40 : column_height
      column_height = render_continuation ? column_height - 20 : column_height
      column_height = render_precedent_link ? column_height - 20 : column_height
      column_height = has_text_overrun ? column_height - 20 : column_height
      column_height = render_offset_leader ? column_height - offset_leader : column_height

      column_height = [column_height, 0].max # Ensure column height is not negative.

      typesetter_service = HtmlTypesetter.new(html, width: text_column_width, height: column_height, line_height: '28px', font_size: '16pt')
      typesetter_service.typeset # Invoke Service
      content = typesetter_service.typeset_html
      html    = typesetter_service.overrun_html

      result << view.render("content/text_column",
        render_by_line: render_by_line,
        author: @text_area.by_line,
        render_continuation: render_continuation,
        continuation_text: continuation_text,
        continuation_path: continuation_path,
        render_precedent_link: render_precedent_link,
        precedent_text: precedent_text,
        precedent_path: precedent_path,
        width: text_column_width,
        height: height,
        content: content,
        has_text_overrun: has_text_overrun,
        offset_leader: offset_leader,
        render_offset_leader: render_offset_leader
      )

    end

    text_area.rendered_html = result
    text_area.overrun_html  = html
  end

private

  def view
    view ||= begin
      view = Object.new #ActionController::Base.new.view_context
      #view.extend ApplicationHelper
      view.extend EditionsHelper
      view.instance_variable_set(:@layout_module, @layout_module)
      LayoutModule::View.new(view)
    end
  end

end
