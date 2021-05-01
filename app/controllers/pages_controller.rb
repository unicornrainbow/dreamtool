class PagesController < ApplicationController

  respond_to :html, :json

  def index
    @pages = Page.asc(:path)
  end

  def new
    @page = Page.new

    # Assign section if passed.
    @page.section = Section.find(params[:section_id]) if params[:section_id]
  end


  def create
    @edition = Edition.find(params[:edition_id])

    @page = @edition.pages.create(page_params)

    respond_with @page
  end


  def destroy
    @edition = Edition.find(params[:edition_id])
    @page = @edition.pages.find(params[:id])
    @page.destroy
    @edition.save

    head :no_content
  end


  #def create
    #if params[:section_id]
      ## TODO: [security] User must have access to the section.
      #@section = Section.find(params[:section_id])
    #end

    #@page = Page.new(page_params)

    #if @section
      #@section.pages << @page
    #end

    ## Set page numbers
    #@page.number = @section.next_page_number

    #@edition = @section.edition
    #@page.pixel_height = @edition.page_pixel_height

    ## All section must have an organization
    #@page.organization = current_user.organization

    #@page.save

    #@section.renumber_pages!

    ##redirect_to :back, notice: "Page created successfully."
    #redirect_to :back
  #end

  def edit
    @page = Page.find(params[:id])
  end

  def show
    @edition = Edition.find(params[:edition_id])
    @page = @edition.pages.find(params[:id])

    if params[:format]
      @composing = params[:composing]
      @section       = @page.section
      @layout_name   = @edition.layout_name
      @layout_module = LayoutModule.new(@layout_name) # TODO: Rename to MediaModule
    end

    respond_with @page, layout: false
  end

  def update
    @edition = Edition.find(params[:edition_id])
    @page = @edition.pages.find(params[:id])
    @page.update_attributes(page_params)
    respond_with [:edition, @page]
  end

  def preview
    # Previews a copy of the section
    @page = Page.find(params[:id])
    render text: PageRenderer.new(@page).render
  end


  def render_page
    @edition = current_user.editions.find(params[:id])

    @page = Page.new(page_params)

    #@edition.content_items << @content_item
    @page.edition = @edition # This is a work around to avoid actually creating the item. Better isolation should be provided in the future

    @section = @page.section

    if params[:format] == 'html'
      @composing = params[:composing]
      @layout_name   = @edition.layout_name
      @layout_module = LayoutModule.new(@layout_name) # TODO: Rename to MediaModule
    end

    render 'show', layout: false
  end


private

  def page_params
    #params.require(:page).permit(:name, :section_id, :source, :layout_id)
    params.fetch(:page, {}).permit(Page.attribute_names)
  end

end
