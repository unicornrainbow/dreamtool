class StoryTextContentItem < ContentItem
  field :columns,       type: Integer, default: 1 # How many columns to render text as.
  field :rendered_html, type: String
  field :overrun_html,  type: String
  field :rendered_at,   type: DateTime

  #belongs_to :story, inverse_of: :story_text_content_items

  # Width of each text column based on width, column count and gutter width.
  def text_column_width
    (width - (columns - 1) * gutter_width) / columns
  end

  def gutter_width
    page.gutter_width # Derived from page
  end

  def typeset!
    EditionStoryTypesetter.new(edition, story).typeset!
  end
end
