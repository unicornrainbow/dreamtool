
class FlickrController < ApplicationController

  def authorize
    flickr = FlickRaw::Flickr.new
    token = flickr.get_request_token(
      :oauth_callback => flickr_auth_callback_url)
        # 'http://localhost:9494/flickr/auth_callback')

    # auth_url = flickr.get_authorize_url(
    #   token['oauth_token'],
    #   :perms => [:read, :create])

    auth_url = flickr.get_authorize_url(
      token['oauth_token'],
      :perms => :read)

    session[:shhh] = token['oauth_token_secret']

    redirect_to auth_url
  end

  def auth_callback
    flickr = FlickRaw::Flickr.new
    oauth_token = params["oauth_token"]
    verify    =    params["oauth_verifier"]

    oauth_secret = session.delete(:shhh)

    flickr.get_access_token(
      oauth_token, oauth_secret, verify)

    current_user.flickr_access_token =
      flickr.access_token
      
    secret = flickr.access_secret
    current_user.flickr_access_secret =
      secret

    login = flickr.test.login
    c = current_user
    c.flickr_username = login.username
    c.flickr_id       = login.id

    current_user.save

    render text:
      "<script type=\"text/javascript\">window.opener.flickrAuthSuccess(); window.close()</script>"

    # render text: "Yeah " + current_user.flickr_username + "!"
  end

  def photos
    flickr = FlickRaw::Flickr.new
    flickr.access_token =
      current_user.flickr_access_token
    flickr.access_secret =
      current_user.flickr_access_secret

    # render text: flickr.photos.getRecent.count


    photos = flickr.photos.search(
               user_id: current_user.flickr_id)

    response = photos.map do |photo|
      photo.as_json.merge({
        url: FlickRaw.url(photo),
        thumbnail_url: FlickRaw.url_t(photo)
      })
    end

    render json: response
  end


  # Create new photos
  # Delete and mod photos app created
  # Can read all photos but can not delete or modify photos app did not create
  # read + private + create
end
