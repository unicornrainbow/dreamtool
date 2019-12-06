class PhotoContentItem < ContentItem
  field :caption, type: String
  field :show_caption, type: Boolean
  field :caption_height, type: Integer
  field :edition_relative_url_path, type: String
  field :clip_path, type: String
  belongs_to :photo

  #def attribute_names
    #super + [:edition_relative_url_path]
  #end

  def photo_url
    # This needs to be relative to the edition
    #photo.attachment.url
  end

  #def edition_relative_url_path
    #photo.try(:edition_relative_url_path)
  #end

end
