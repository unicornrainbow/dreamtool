class PrintsController < ApplicationController
  before_action :find_edition, only: [:index, :create]

  def index
    @prints = @edition.prints
  end

  def create
    @print = @edition.prints.create
    @print.print_start
    redirect_to :back, notice: "Print Started"
  end

  def download
    @print = Print.find(params["id"])
    @edition = @print.edition
    send_file @print.zip_path
  end

  def show
    @edition = Edition.find(params["edition_id"])
    @print = @edition.prints.where(version: params["id"]).first # Look up by version
    send_file "#{@print.share_path}/#{params[:path]}.#{params[:format]}", disposition: :inline
  end

  def view
    @print = Print.find(params["id"])
    send_file "#{@print.share_path}/#{params[:path]}.#{params[:format]}", disposition: :inline
  end

  def update
    @print = Print.find(params[:id])
    @print.update_attributes(print_params)
    redirect_to :back
  end

  def publish
    @print = Print.find(params[:id])
    @print.publish_print_to_store
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

  def print_params
    params.require(:print).permit(:signature, :state_event)
  end

end
