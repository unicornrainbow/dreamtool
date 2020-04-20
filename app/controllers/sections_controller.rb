class SectionsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def index
    @sections = Section.asc(:path)
  end

  def new
    if params[:edition_id]
      @edition = Edition.find(params[:edition_id])
      @section = @edition.sections.build
    else
      @section = Section.new
    end
  end

  def create
    @section = Section.new(section_params)

    # All section must have an organization
    @section.organization = current_user.organization

    if @section.save
      redirect_to @section, notice: "Section created successfully."
    else
      render "new"
    end
  end

  def edit
    @edition = Edition.find(params[:edition_id])
    @section = @edition.sections.find(params[:id])
  end

  def update
    @edition = Edition.find(params[:edition_id])
    @section = @edition.sections.find(params[:id])
    section_params.delete('edition_id')
    @section.update_attributes(section_params)
    redirect_to :back
  end

  def show
    @section = Section.find(params[:id])
    @edition = @section.edition
    @pages = @section.pages
  end

  def destroy
    @section = Section.find(params[:id])
    @edition = @section.edition
    @section.destroy
    redirect_to compose_edition_path(@edition)
  end

  def preview
    # Previews a copy of the section
    @section = Section.find(params[:id])
    render text: SectionRenderer.new(@section).render
  end

private

  def section_params
    params.require(:section).permit(:name, :edition_id, :layout_id, :path, :sequence, :template_name, :page_title, :letter)
  end

end
