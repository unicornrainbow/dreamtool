class Color
  include Mongoid::Document

  embedded_in :edition

  field :name,   type: String
  field :value,  type: String
  field :key,    type: String
  field :index,  type: Integer

  def to_s
    value
  end

end
