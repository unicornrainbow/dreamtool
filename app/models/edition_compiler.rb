require 'fileutils'
require 'securerandom'

# Compile and entire edition
class EditionCompiler

  attr_reader :edition, :html, :output_dir

  def initialize(edition)
    @edition = edition
  end

  def compile!
    @output_dir = Rails.root.join('tmp', 'prints', SecureRandom.hex)
    # Clean output directory
    #FileUtils.rm_rf output_dir
    FileUtils.mkdir_p @output_dir

    sections = edition.sections
    stylesheet_assets = []
    javascript_assets = []
    sections.each do |section|
      sc = SectionCompiler.new(section)
      sc.compile!
      stylesheet_assets += sc.asset_recorder.stylesheet_assets
      javascript_assets += sc.asset_recorder.javascript_assets
      File.write(@output_dir.join(section.path), sc.html)
    end

    environment = Sprockets::Environment.new
    environment.append_path File.join(@edition.layout_module_root, "stylesheets")
    environment.append_path File.join(@edition.layout_module_root, "javascripts")

    # Major hack to load bootstrap into this isolated environment courtesy of https://gist.github.com/datenimperator/3668587
    Bootstrap.load!
    environment.append_path Compass::Frameworks['bootstrap'].templates_directory + "/../vendor/assets/stylesheets"

    environment.context_class.class_eval do
      def asset_path(path, options = {})
        "/assets/#{path}"
      end
    end

    # Hack to load paths for jquery and angular gems
    environment.append_path Gem.loaded_specs['angularjs-rails'].full_gem_path + "/vendor/assets/javascripts"
    environment.append_path Gem.loaded_specs['jquery-rails'].full_gem_path + "/vendor/assets/javascripts"

    # Stylesheets
    stylesheet_assets.uniq!
    stylesheet_assets.each do |stylesheet_path|
      path = stylesheet_path.split('/').tap(&:shift).join('/') # Remove leading stylesheet/
      result = environment[path]

      FileUtils.mkdir_p File.expand_path('..', @output_dir.join(stylesheet_path))
      File.write(@output_dir.join(stylesheet_path), result)
    end

    # Javascripts
    javascript_assets.uniq!
    javascript_assets.each do |javascript_path|
      path = javascript_path.split('/').tap(&:shift).join('/') # Remove leading javascript/
      result = environment[path]

      FileUtils.mkdir_p File.expand_path('..', @output_dir.join(javascript_path))
      File.write(@output_dir.join(javascript_path), result)
    end

    # Fonts
    # For now, just copy fonts from the media module
    FileUtils.cp_r File.join(@edition.layout_module_root, "fonts"), @output_dir.join('fonts')

    # Copy images from media module
    FileUtils.cp_r File.join(@edition.layout_module_root, "images"), @output_dir.join('images')

    # Collect and render content Image assets
    FileUtils.mkdir_p @output_dir.join('images')
    photos = edition.resolve_photos
    photos.each do |photo|
      # TODO: Would be great to know the size to be rendered from the photo
      # content item, and included specifically for that. Need to make sure to
      # be sizing the images appropraitly.
      FileUtils.cp photo.attachment.path, @output_dir.join(photo.edition_relative_url_path)
    end


    # Collect videos and video cover images
    FileUtils.mkdir_p @output_dir.join('videos')
    videos = edition.resolve_videos
    videos.each do |video|
      # TODO: Would be great to know the size to be rendered from the photo
      # content item, and included specifically for that. Need to make sure to
      # be sizing the images appropraitly.
      FileUtils.cp video.video_file.path, @output_dir.join(video.video_url)
      # TODO: May run into conflict with similarily name files. (Something to
      # check for in the future.)
      FileUtils.cp video.cover_image.path, @output_dir.join(video.cover_image_url)
    end

    # TODO: Collect and render consumed media module assets (Images...)
  end

end
