class Partial
  include Mongoid::Document
  field :name, type: String
  field :source, type: String
end
