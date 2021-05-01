attributes *Edition.attribute_names

child :sections => :sections_attributes do
  attributes *Section.attribute_names
end

child :pages => :pages_attributes do
  attributes *Page.attribute_names
  attributes :page_ref
end

child :content_items => :content_items_attributes do |content_items|
  content_items.map do |content_item|
    attributes *content_item.attribute_names
  end
end

child :groups => :groups_attributes do |groups|
  groups.map do |group|
    attributes *group.attribute_names
  end
end

child :colors => :colors_attributes do
  attributes *Color.attribute_names
end

child :masthead_artwork => :masthead_artwork_attributes do
  attributes :height, :lock
end
