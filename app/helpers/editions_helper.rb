module EditionsHelper
  attr_reader *[
    :layout_module,
    :edition,
    :section,
    :composing,
    :template_name,
    :title
  ]

  attr_accessor :layouts

  alias :composing? :composing

  attr_accessor :asset_recorder

  def layouts
    @layouts ||= []
  end

  def wrap_with(*args)
    layouts << args
  end

  def yield_content(&block)
    content = capture(&block)

    # Decorate view with layout module particularities.
    view = LayoutModule::View.new(self)

    while layout = layouts.pop
      template_name = layout.shift
      template = layout_module.templates[template_name]
      content = template.render(view, *layout) { content }.html_safe
    end

    concat(content)
  end


  # TODO: In time, this logic should be reverse to not rely on exceptions and to
  # check with the layout module first to allow more flexiable overriding.
  def render(name, *args)
    super(name, *args)
  rescue ActionView::MissingTemplate
    view = LayoutModule::View.new(self)
    template = layout_module.templates[name]
    template.render(view, *args).html_safe
  end

  def composer_stylesheet
    stylesheet_link_tag("composer") + "\n"
  end

  def composer_javascript
    content = content_for(:composer_variables)
    if @mobile
      content << javascript_include_tag("mobile-composer") + "\n"
    else
      content << javascript_include_tag("composer") + "\n"
    end
  end


  def underscore_key(key)
    key.to_s.underscore.to_sym
  end

  #def convert_hash_keys(hash)
    #Hash[hash.map { |k, v| [underscore_key(k), v] }]
  #end

  #def slice(object, *keys)
    #Hash[keys.map { |key|  [key, object.send(key)] }]
  #end

  def render_content_item(content_item, options={})
    content = ""

    options[:id]     = content_item.id
    options[:top]    ||= content_item.top.to_i - content_item.page.top.to_i
    options[:left]   ||= content_item.left
    options[:width]  = content_item.width
    options[:height] = content_item.height
    options[:z_index] = content_item.z_index

    content << case content_item
    when HeadlineContentItem then
      options[:style] = content_item.style

      options[:text] = if content_item.text
        text = content_item.text.dup
        text.gsub(/(?:\n\r?|\r\n?)/, '<br>') # Convert newlines into linebreaks
      else
        ''
      end

      render "content/headline", options
    when StoryTextContentItem then
      render "content/story", id: content_item.id, anchor: content_item.id, rendered_html: content_item.rendered_html
    when TextAreaContentItem then
      options[:text] = content_item.text
      options[:anchor] = "#{content_item.page.page_ref}/#{content_item.story_title}"
      options[:rendered_html] = content_item.rendered_html
      options[:shape] = content_item.shape

      render "content/text_area", options
    when PhotoContentItem then
      options[:photo_url]     = content_item.edition_relative_url_path
      options[:caption]  = content_item.caption
      options[:caption_height]  = content_item.caption_height
      options[:photo_width]   = content_item.width
      #options[:photo_height]  = content_region.width / content_item.photo.aspect_ratio
      options[:photo_height]  = content_item.height - content_item.caption_height.to_i
      options[:show_caption]  = content_item.show_caption
      options[:clip_path] = content_item.clip_path
      render "content/photo", options
    when VideoContentItem then

      # Find video by name
      if content_item.video_name
        video = Video.find_by(name: content_item.video_name)
      end

      options[:video_url]          = video.try(:video_url)
      options[:video_thumbnail]    = video.try(:cover_image_url)
      options[:video_aspect_ratio] = video.try(:aspect_ratio)

      options[:caption]            = content_item.try(:caption)
      options[:show_caption]       = content_item.try(:show_caption)
      options[:caption_height]     = content_item.try(:caption_height)

      #options[:video_url]         = content_item.video_url
      #options[:video_thumbnail]   = content_item.cover_image_url

      render "content/video", options
    when DividerContentItem then
      width  = content_item.width || 0
      height = content_item.height || 0
      options[:orientation]  = content_item.orientation

      thickness = content_item.thickness || "1"
      if thickness
        thickness   = thickness.split(' ')
        thickness   = thickness.map { |val| val.to_i }
        thicknessSum = thickness.sum || 0
      end


      if content_item.orientation == 'vertical'
        margin = (width - thicknessSum) / 2
        options[:border_width]  = "0 #{thickness[2] ? thickness[2] : 0}px 0 #{thickness[0]}px"
        options[:margin] = "0 #{margin}px"
        options[:width] = thickness[1] || 0
      else
        margin = (height - thicknessSum) / 2
        options[:border_width]  = "#{thickness[0]}px 0 #{thickness[2] ? thickness[2] : 0}px 0"
        options[:margin] = "#{margin}px 0"
        options[:height] = thickness[1] || 0
      end

      render "content/divider", options
    when HTMLContentItem then
      options[:html] = content_item.try(:HTML) || ''
      options[:html] = options[:html].sub('{{height}}', content_item.height.to_s)
      options[:html] = options[:html].sub('{{width}}', content_item.width.to_s)
      render "content/html", options
    when BoxContentItem then
      options = {}
      options[:id]     = content_item.id

      render "content/box", options
    end
    content
  end

  def fetch_story_fragment(story_name, fragment_index, last_mod_time)
    fragment = $dalli.get "story_fragments/#{story_name}/#{fragment_index}"

    unless fragment && last_mod_time == fragment[:last_mod_time]
      Rails.logger.info "Typesetting Story: #{story_name}, Fragment Index: #{fragment_index}"
      fragment = {
        last_mod_time: last_mod_time,
        payload: yield
      }
      $dalli.set "story_fragments/#{story_name}/#{fragment_index}", fragment
    end

    fragment[:payload]
  end

  # Resolves the color to a CSS value, haha!
  def resolve_color(value)
    edition.colors.each do |color|
      return color if color.name == value
    end
    value
  end

end
