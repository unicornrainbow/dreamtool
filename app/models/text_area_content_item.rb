class TextAreaContentItem < ContentItem
  field :columns,       type: Integer, default: 1 # How many columns to render text as.
  field :text,          type: String, default: ""
  field :rendered_html, type: String
  field :overrun_html,  type: String
  field :rendered_at,   type: DateTime
  field :by_line,       type: String
  field :show_by_line,  type: Boolean, default: false
  field :story_title,   type: String  # String key used for lacing text areas together
  field :overflow_input_text, type: String
  field :shape, type: String

  field :offset_leader, type: Integer

  field :overflow_input_text, type: String

  field :lead_text_area_id,     type: BSON::ObjectId
  field :follow_text_area_id,     type: BSON::ObjectId

  field :precedent_text, type: String
  field :continuation_text, type: String

  field :continuation_path, type: String
  field :precedent_path, type: String

  # Width of each text column based on width, column count and gutter width.
  def text_column_width
    (width - (columns - 1) * gutter_width) / columns
  end

  def lead_text_area
    @lead_text_area ||= lead_text_area_id && edition.content_items.find(lead_text_area_id)
  end

  def follow_text_area
    @follow_text_area ||= follow_text_area_id && edition.content_items.find(follow_text_area_id)
  end

  delegate :gutter_width => :page

  # def line_height
    # See etc.default_layout/config.yml

    # 28
  # end

  def typeset!(layout_module)
    TextAreaTypesetter.new(self, layout_module).typeset!
  end

  def anchor
    id
  end

end
