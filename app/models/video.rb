class Video
  include Mongoid::Document
  field :name, type: String
  field :aspect_ratio, type: Float

  include Mongoid::Paperclip
  has_mongoid_attached_file :video_file
  has_mongoid_attached_file :cover_image

  # Extract and set a cover image from the video source.
  def extract_cover!(offset=0.0)
    random_name = (0...8).map { (65 + rand(26)).chr }.join
    tmp_file = "tmp/#{random_name}.jpg"

    `ffmpeg -itsoffset -#{offset} -i '#{video_file.path}' -vframes 1 -an #{tmp_file}`

    # Attach output image as cover image
    File.open(tmp_file) do |f|
      self.cover_image = f
      save
    end
  end

  # Measures and sets the aspect ratio from the video file.
  def set_aspect_ratio!
    # ffprobe to read video infomation http://stackoverflow.com/a/6385938
    json = `ffprobe -i '#{video_file.path}' -show_streams -print_format json`
    json = JSON.parse(json)
    stream = json['streams'][0]
    width  = stream['width'].to_f
    height = stream['height'].to_f
    self.update_attribute :aspect_ratio, (width/height).round(4)
    self.save!
  end

  def location
    video_file.path
  end

  def video_url
    # Note: Edition relative
    "videos/#{name}#{File.extname(video_file.path)}"
  end

  def cover_image_url
    "images/#{name}#{File.extname(cover_image.path)}"
  end


end
