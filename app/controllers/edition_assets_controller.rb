class EditionAssetsController < ApplicationController
  #before_action :authenticate_user!
  respond_to :html

  before_action :find_edition

  protect_from_forgery except: :javascripts
  def javascripts

    $sprocket_js_environments ||= {}
    environment = $sprocket_js_environments[@edition.layout_module_root]
    unless environment
      # Load environment into global cache.
      environment = Sprockets::Environment.new
      environment.append_path File.join(@edition.layout_module_root, "javascripts")

      # Hack to load paths for jquery and angular gems
      environment.append_path Gem.loaded_specs['angularjs-rails'].full_gem_path + "/vendor/assets/javascripts"
      environment.append_path Gem.loaded_specs['jquery-rails'].full_gem_path + "/vendor/assets/javascripts"

      $sprocket_js_environments[@edition.layout_module_root] = environment
    end

    result = environment["#{params[:path]}"]

    render body: result, content_type: "text/javascript"
  end

  def stylesheets

    $sprocket_environments ||= {}
    environment = $sprocket_environments[@edition.layout_module_root]
    unless environment
      # Load environment into global cache.
      environment = Sprockets::Environment.new
      environment.append_path File.join(@edition.layout_module_root, "stylesheets")
      environment.append_path Gem.loaded_specs['compass'].full_gem_path + "/frameworks/compass/stylesheets"

      environment.context_class.class_eval do
        def asset_path(path, options = {})
          "/assets/#{path}"
        end
      end

      $sprocket_environments[@edition.layout_module_root] = environment
    end

    result = environment["#{params[:path]}.css"]
    render body: result, content_type: "text/css"
  end

  def fonts
    fonts_root = File.join(@edition.layout_module_root, "fonts")


    # TODO: WARNING: Make sure the user can't escape up about the font root (Chroot?)
    font_path = "#{fonts_root}/#{params["path"]}.#{params["format"]}"
    not_found unless File.exists?(font_path)
    send_file font_path
  end


  def images

    # Find photo with the same name, from edition photos (Could be hashed)
    # TODO: Would be nice if this find was scoped better to the edition to avoid
    # name conflicts.
    photo = Photo.where(name: params[:path]).first
    if photo
      send_file photo.attachment.path, disposition: :inline
    else
      # No content image found, check against videos
      video = Video.where(name: params[:path]).first

      if video
        send_file video.cover_image.path, disposition: :inline
      else
        # No video cover found, serve from layout

        images_root = File.join(@edition.layout_module_root, "images")

        # TODO: WARNING: Make sure the user can escape up about the font root (Chroot?)
        image_path = "#{images_root}/#{params["path"]}.#{params["format"]}"
        not_found unless File.exists?(image_path)

        #render text: File.read(image_path), content_type: 'image/svg+xml' # NOTE: This seems to be left over from serving svg data, may be useful later
        send_file image_path, disposition: :inline
      end
    end
  end

  def videos

    # Find video with the same name, from edition photos (Could be hashed)
    # TODO: Would be nice if this find was scoped better to the edition to avoid
    # name conflicts.
    video = Video.find_by(name: params[:path])

    file_begin = 0
    file_size = File.stat(video.location).size
    file_end = file_size - 1

    if !request.headers["Range"]
      status_code = :ok
    else
      status_code = :partial_content
      match = request.headers['Range'].match(/bytes=(\d+)-(\d*)/)
      if match
        file_begin = match[1]
        file_end = match[2] if match[2] && !match[2].empty?
      end
      response.header["Content-Range"] = "bytes " + file_begin.to_s + "-" + file_end.to_s + "/" + file_size.to_s
    end
    response.header["Content-Length"] = (file_end.to_i - file_begin.to_i + 1).to_s

    response.header["Accept-Ranges"]=  "bytes"
    response.header["Content-Transfer-Encoding"] = "binary"


    #send_file video.video_file.path, disposition: nil

    send_file video.video_file.path,
      filename: File.basename(video.location),
      type: 'video/mp4',
      disposition: :inline,
      status: status_code,
      stream:  'true',
      buffer_size:  4096

  end

end
