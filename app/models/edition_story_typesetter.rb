# Type sets StoryTextContentItems for a edition/story pair.
require "net/http"
require "uri"

class EditionStoryTypesetter
  attr_reader :edition, :story

  def initialize(edition, story)
    @edition = edition
    @story = story
  end

  # Typesets content items.
  def typeset!(force=false)
    content_items = get_content_items_in_sequence

    html = $markdown.render(story.body)
    doc = Nokogiri::HTML(html)
    elements = doc.css("body > p")
    html = elements.to_html

    previous_content_item = nil
    next_content_item = nil

    [nil, *content_items, nil].each_cons(3) do |prev, content_item, nxt|
      include_by_line = !prev # If first
      include_continuation = !!nxt # If has next
      include_precedent_link = !!prev # If has prev

      result = ""
      height             = content_item.height
      text_column_width  = content_item.text_column_width
      column_count       = content_item.columns
      column_count.times do |column_index|
        render_by_line = include_by_line && column_index.zero?
        render_continuation = include_continuation && column_index + 1 == column_count
        render_precedent_link = include_precedent_link && column_index.zero?

        if render_continuation
          trailing_page = nxt.page
          trailing_section = trailing_page.section
          continuation_text = "Continued on Page #{trailing_page.page_ref}"
          continuation_path = "#{trailing_section.path}#page-#{trailing_page.number}"
        end

        if render_precedent_link
          # stiched could also work
          leading_page = prev.page
          leading_section = leading_page.section
          precedent_text = "Continued from Page #{leading_page.page_ref}"
          precedent_path = "#{leading_section.path}#page-#{leading_page.number}"
        end


        # Has text overrun, should be determined on the
        is_last_column = column_index + 1 == column_count
        has_text_overrun = html && !render_continuation && is_last_column


        column_height = height
        column_height = render_by_line ? column_height - 40 : column_height
        column_height = render_continuation ? column_height - 20 : column_height
        column_height = render_precedent_link ? column_height - 20 : column_height
        column_height = has_text_overrun ? column_height - 20 : column_height

        typesetter_service = HtmlTypesetter.new(html, width: text_column_width, height: column_height)
        typesetter_service.typeset # Invoke Service
        content = typesetter_service.typeset_html
        html    = typesetter_service.overrun_html


        result << view.render("content/text_column",
          story: story,
          render_by_line: render_by_line,
          render_continuation: render_continuation,
          continuation_text: continuation_text,
          continuation_path: continuation_path,
          render_precedent_link: render_precedent_link,
          precedent_text: precedent_text,
          precedent_path: precedent_path,
          width: text_column_width,
          height: height,
          content: content,
          has_text_overrun: has_text_overrun
        )

      end

      content_item.rendered_html = result
      content_item.overrun_html  = html
      content_item.save
    end

  end

  # Return story text content items for the edition/story
  def get_content_items_in_sequence
    content_items = story.story_text_content_items.to_a

    # Reject, unless for the same edition
    content_items.select! do |content_item|
      content_item.edition.id == edition.id
    end

    # Order them based on Section Sequence -> Page Number -> Content Region Row -> Content Region Sequence -> Content Item Sequence
    content_items.sort do |a, b|
      # Section
      result = a.section.sequence <=> b.section.sequence
      result.zero? or next result

      # Page
      result = a.page.number <=> b.page.number
      result.zero? or next result

      # Content Region Row
      result = a.content_region.row_sequence <=> b.content_region.row_sequence
      result.zero? or next result

      # Content Region Sequence
      result = a.content_region.sequence <=> b.content_region.sequence
      result.zero? or next result

      # Finally, Content Region Sequence
      result = (a.sequence <=> b.sequence)
    end
  end

private

  def view
    view ||= begin
               view = Object.new #ActionController::Base.new.view_context
               #view.extend ApplicationHelper
               view.extend EditionsHelper
               view.instance_variable_set(:@layout_module, LayoutModule.new('sfrecord'))
               LayoutModule::View.new(view)
             end
  end

end
