class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :screenname,         type: String, default: ""
  field :password_digest
  field :email

  # field :screenname_casing,  type: Integer, default: 0 # Bitmask applied to screenname to get user desired casing.

  field :reset_password_token,  type: String
  field :reset_password_sent_at,  type: Time
  field :signup_date

  field :first_name
  field :last_name
  field :prefix
  field :suffix

  # Flickr
  field :flickr_id
  field :flickr_username
  field :flickr_access_token
  field :flickr_access_secret #, type: Mongoid::EncryptedString
  # field :flickr_access_secret, encrypt: true, key: FLICKR_KEY

  field :remember_created_at, type: Date

  field :admin, type: Boolean

  has_many :editions
  has_many :publications
  has_many :photos
  has_many :videos
  has_many :stories

  embeds_one :workspace
  accepts_nested_attributes_for :workspace

  # Validations
  validates :screenname, presence: true, uniqueness: true
  validates :email, presence: true

  # validates_confirmation_of :password
  # validates :password, confirmation: true

  index({ screenname: 1 }, { unique: true, name: "screenname_index" })

  has_secure_password

  def has_password?
    !!password_digest
  end

  # Applies int bitmask to screenname for casing.
  #
  # A bitmask of 1 captializes the first letter, so
  # essentially the bitmask is applied in reverse.
  def apply_bitmask(screenname, bitmask)
    k=[]
    i=screenname.length
    while i > 0
      i-=1
      r = 2**i
      if bitmask >= r
        bitmask -= r
        k << 1
      else
        k << 0
      end
    end
    k=k.reverse
    i=0
    screenname.split('').map do |char|
      if k[i] == 1
        char.upcase
      else
        char.downcase
      end.tap { i+=1 }
    end.join
  end

  # Return bitmask as an integer value.
  def get_bitmask(screenname)
    k = screenname.split('').map do |char|
      char =~ /[A-Z]/ ? 1 : 0
    end
    i=0
    k.reduce(0) do |v, x|
      result = v + x.to_i * 2**i
      i = i+1
      result
    end
  end


  # before_save do
  #   if screenname_changed?
  #     # Capture screenname casing bitmask and strip casing.
  #     self.screenname_casing = get_bitmask(screenname)
  #     self.screenname = screenname.downcase
  #   end
  # end

end
