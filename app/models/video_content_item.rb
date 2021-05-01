class VideoContentItem < ContentItem
  field :video_name, type: String
  field :caption, type: String
  field :show_caption, type: Boolean
  field :aspect_ratio, type: Float
  field :caption_height, type: Integer

  belongs_to :video


  def video_url
    # Note: Edition relative
    video.try(:video_url)
  end

  def cover_image_url
    video.try(:cover_image_url)
  end

  def aspect_ratio
    Video.find_by(name: video_name).try(:aspect_ratio) if video_name
  end
end
