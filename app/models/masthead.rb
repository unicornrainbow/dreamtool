class Masthead
  include Mongoid::Document

  embedded_in :edition

  field :height, type: Integer
  field :lock,   type: Boolean

  field :artwork_height, type: Integer

  include Mongoid::Paperclip
  has_mongoid_attached_file :artwork

end
