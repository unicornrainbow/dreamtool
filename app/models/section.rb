class Section
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in  :edition

  ## Attributes
  field :name, type: String
  field :page_title, type: String
  field :path, type: String
  field :sequence, type: Integer
  field :letter, type: String
  field :template_name, type: String
  field :ordinal, type: Integer

  def pages
    edition.pages.where(section_id: id)
  end

  def content_items
    edition.content_items.where(page_id: pages.map(&:id))
  end

  def edition_id
    edition.id
  end

  ## Methods

  def renumber_pages!
    # For each page, number pages.
    pages.asc(:number).each_with_index do |page, i|
      page.update_attribute(:number, i+1) if page.number != i+1
    end
  end

  def next_page_number
    pages.max(:number).to_i + 1
  end

end
