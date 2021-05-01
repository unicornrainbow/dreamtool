class MastheadArtwork
  include Mongoid::Document
  include Mongoid::Paperclip

  field :width, type: Integer
  field :height, type: Integer
  field :aspect_ratio, type: Float
  field :lock, type: Boolean

  belongs_to :edition

  has_mongoid_attached_file :attachment

  before_save :extract_dimensions

  def image?
    attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end

private

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  def extract_dimensions
    return unless image?
    tempfile = attachment.queued_for_write[:original]
    unless tempfile.nil?
      geometry = Paperclip::Geometry.from_file(tempfile)
      self.width, self.height = [geometry.width.to_i, geometry.height.to_i]
      self.aspect_ratio = width.to_f/height
    end
  end


end
