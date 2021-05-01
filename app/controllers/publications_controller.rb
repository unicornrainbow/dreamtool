
class PublicationsController < ApplicationController

  respond_to :html

  def index
    #@publications = current_user.publications.desc(:updated_at)
    @publications = Publication.all.desc(:updated_at)
  end

  def new
    @publication = Publication.new
  end

  def create
    @publication = Publication.new(publication_params)

    # All edtions must have an orgnaization
    #@publication.organization = current_user.organization
    #@publication.user = current_user

    if @publication.save
      redirect_to @publication, notice: "Publication created successfully."
    else
      render "new"
    end
  end

  def update
    @publication = Publication.find(params[:id])
    if @publication.update_attributes(publication_params)
      redirect_to @publication, notice: "Publication updated successfully."
    else
      render "edit"
    end
  end

  def show
    @publication = Publication.find(params[:id])
  end

  def show_by_name
    @publication = Publication.
      find_by(name: params[:name])
    render :show      
  end

  def destroy
    @publication = Publication.find(params[:id]).destroy
    redirect_to publications_path, notice: "Publication deleted successfully."
  end

private

  def publication_params
    params.require(:publication).permit(:name, :default_layout_name, :store_url, :default_price, :website_url, :default_section_attributes)
  end

end
