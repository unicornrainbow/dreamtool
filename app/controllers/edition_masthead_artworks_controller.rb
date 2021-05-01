class EditionMastheadArtworksController < ApplicationController
  respond_to :json, :html

  before_action :find_edition

  def new
    @masthead_artwork = MastheadArtwork.new
  end

  def create
    @masthead_artwork = MastheadArtwork.new(masthead_artwork_params)
    @masthead_artwork.save

    @edition.masthead_artwork = @masthead_artwork
    @edition.save

    redirect_to :back
  end

private

  def find_edition
    if params[:edition_id].length == 24
      @edition = Edition.find(params[:edition_id])
    else
      @edition = current_user.editions.find_by(slug: params[:edition_id])
    end
  end

  def masthead_artwork_params
    params.require(:masthead_artwork).permit(:name, :attachment)
  end

end
