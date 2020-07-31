class Signup
  include Mongoid::Document

  validates :screenname, presence: true

  attr_accessor :email

  field :screenname
  field :first_name
  field :last_name
  field :prefix
  field :suffix

  attr

end
