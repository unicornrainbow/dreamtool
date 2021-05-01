class Page
  include Mongoid::Document
  # include Mongoid::Timestamps

  embedded_in :edition

  field      :name,         type: String
  field      :source,       type: String
  field      :number,       type: Integer
  field      :pixel_height, type: Integer
  field      :section_id,   type: BSON::ObjectId

  # Fields for capturing page boundries
  field :top, type: Integer
  field :left, type: Integer
  field :bottom, type: Integer # Bottom boudry, relative to top zero
  field :right, type: Integer  # Right boundry, relative to left zero

  def section
    section_id && edition.sections.find(section_id)
  end

  def section=(section)
    self.section_id = section.id
    #&& edition.sections.find(section_id)
  end

  def content_items
    edition.content_items.where(page_id: id)
  end

  def groups
    edition.groups.where(page_id: id)
  end

  def pixel_height
    self[:pixel_height] || 1552
  end

  def gutter_width
    16 # Stand-in Value
  end

  def next_content_region_sequence
    (content_regions.max(:sequence) || 0) + 1
  end

  def resequence_content_regions!
    content_regions.asc(:sequence).each_with_index do |content_region, i|
      content_region.update_attribute(:sequence, i+1) if content_region.sequence != i+1
    end
  end

  def page_ref
    # "#{section.letter}#{number}"
  end

  def grid_composition
    @grid_composition ||= GridComposition.new(self)
  end
end
