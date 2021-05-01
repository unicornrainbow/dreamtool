# IDEA: Perhaps all of this stuff should be in a content module to keep it seperate
# from the rest of the app?

class ContentItem
  include Mongoid::Document
  # include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :edition

  TYPE_COLLECTION = content_item_types = [
    ["Headline", "HeadlineContentItem"],
    ["Story", "StoryTextContentItem"],
    ["Photo", "PhotoContentItem"],
    ["Video", "VideoContentItem"],
    ["Horizontal Rule", "HorizontalRuleContentItem"]
  ]

  ## Attributes
  field    :_type,          type: String
  field    :sequence,       type: Integer
  field    :page_id,        type: BSON::ObjectId
  field    :group_id,       type: BSON::ObjectId
  field    :top,            type: Integer
  field    :left,           type: Integer
  field    :width,          type: Integer
  field    :height,         type: Integer
  field    :z_index,        type: Integer

  def page
    @page ||= page_id && edition.pages.find(page_id)
  end

  def page=(page)
    @page        = page
    self.page_id = @page.id
  end

  def group
    @group ||= group_id && edition.groups.find(group_id)
  rescue
    nil
  end

  def group=(value)
    @group, self.group_id = value, value.id
  end

  def section
    @section ||= page.section
  end

  # Top, relative to page (Underlying value is relative to canvas)
  def parent_relative_top
    top - (parent.try(:top) || 0)
  end

  # Left, relative to page (Underlying value is relative to canvas)
  def parent_relative_left
    left - (parent.try(:left) || 0)
  end

  def parent
    group || page
  end

end
