class Organization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :users
  has_many :editions
  has_many :sections
  has_many :stylesheets
  has_many :javascripts
  has_many :publications

end
