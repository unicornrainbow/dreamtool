require 'wiki_parser'

class AttachmentsController < ApplicationController

  before_action :sanitize_path

  def sanitize_path
    if params[:path]
      # No relative linking
      #params[:path].gsub!(/\.\.\//, '/')
    end
  end

  def index
    date = Date.today - params[:days_ago].to_i.days
    @formatted_date = date.strftime('%A, %B %e %Y')
    root_path = "#{Attachment::ATTACHMENT_ROOT}/"

    today_path = "#{root_path}#{date.strftime("%Y/%m/%d")}"
    todays_entries = Dir["#{today_path}/*.*"]

    @attachments = todays_entries.map { |full_path|
      path, ext = full_path.match(/#{root_path}(.*)\.(.*)$/).try(:captures)
      path_ext = "#{path}.#{ext}"
      basename = File.basename(path)
      created_at = parse_created_at("#{path}.#{ext}")

      attributes = {
        name: path,
        path_ext: path_ext,
        ext: ext,
        path: "/attachments/#{path}",
        download_path: "/attachments/#{path_ext}"
      }
      OpenStruct.new(attributes)
    }

    @attachments.reverse!

  end

  def show
    date = Date.today - params[:days_ago].to_i.days
    root_path = "#{Attachment::ATTACHMENT_ROOT}/"
    path = "#{Attachment::ATTACHMENT_ROOT}/#{params[:path]}"
    path, ext = path.match(/#{root_path}(.*)\.(.*)$/).try(:captures)
    path_ext = "#{path}.#{ext}"

    basename = File.basename(path)
    created_at = parse_created_at("#{path}")

    # Need to be able to figure out thefile
    #send_file "#{Attachment::ATTACHMENT_ROOT}/#{params[:path]}.png"

    File.exists?("#{root_path}#{path}.#{ext}") or not_found

    attributes = {
      name: path,
      path_ext: path_ext,
      ext: ext,
      path: "/attachments/#{path}",
      download_path: "/attachments/#{path_ext}"
    }
    @attachment = OpenStruct.new(attributes)
  end

  def download
    date = Date.today - params[:days_ago].to_i.days
    root_path = "#{Attachment::ATTACHMENT_ROOT}/"
    full_path = "#{Attachment::ATTACHMENT_ROOT}/#{params[:path]}.#{params[:format]}"

    path, ext = full_path.match(/#{root_path}(.*)\.(.*)$/).try(:captures)
    path_ext = "#{path}.#{ext}"


    #basename = File.basename(path)
    #created_at = parse_created_at("#{path}")

    ## Need to be able to figure out thefile

    #File.exists?("#{root_path}#{path}.#{ext}") or not_found

    send_file "#{Attachment::ATTACHMENT_ROOT}/#{path_ext}"
  end


private

  def parse_created_at(path)
    # Parse created at
    #2013/23/23/23:23:23.txt'
    date, name = path.match(/(\d{2,4}\/\d{1,2}\/\d{1,2})\//).try(:captures)
    Date.parse("#{date}") # Might need some conrrection for timezone.
  end

end
