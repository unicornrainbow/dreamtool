class Stylesheet
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :source, type: String

  belongs_to :organization
end
