class Javascript
  include Mongoid::Document

  field :name, type: String
  field :source, type: String


  belongs_to :organization
end
