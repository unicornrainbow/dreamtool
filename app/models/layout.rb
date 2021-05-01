class Layout
  include Mongoid::Document
  field :name, type: String
  field :source, type: String

  belongs_to :parent_layout, class_name: "Layout"
end
