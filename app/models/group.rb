class Group < ContentItem
  include Mongoid::Document
  # include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  embedded_in :edition

  field    :page_id,        type: BSON::ObjectId
  field    :group_id,       type: BSON::ObjectId # If a sub group
  field    :top,            type: Integer
  field    :left,           type: Integer
  field    :width,          type: Integer
  field    :height,         type: Integer
  field    :z_index,        type: Integer
  field    :left_border,    type: Boolean  # Experimental for storing if there is a left border.
  field    :story_title,    type: String  # String key used for lacing text areas together


  def content_items
    edition.content_items.where(group_id: id)
  end

  def groups
    edition.groups.where(group_id: id)
  end
end
