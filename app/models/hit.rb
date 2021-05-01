class Hit
  include Mongoid::Document
  # include Mongoid::Timestamps


  field :ip
  field :url
  field :date
end
