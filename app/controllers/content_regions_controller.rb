class ContentRegionsController < ApplicationController

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def index
    @content_regions = ContentRegion.asc(:path)
  end

  def new
    @content_region = ContentRegion.new

    # Assign section if passed.
    @content_region.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
     @page_id = params[:page_id] || content_region_params[:page_id]
    if @page_id
      # TODO: [security] User must have access to the section.
      @page = Page.find(@page_id)
    end

    @content_region = ContentRegion.new(content_region_params)

    if @page
      @page.content_regions << @content_region
    end

    # Set content_region numbers
    @content_region.sequence = @page.next_content_region_sequence

    # All section must have an organization
    @content_region.organization = current_user.organization

    @content_region.save

    @page.resequence_content_regions!

    #redirect_to :back, notice: "ContentRegion created successfully."
    redirect_to :back
  end

  def edit
    @content_region = ContentRegion.find(params[:id])
  end

  def show
    @content_region = ContentRegion.find(params[:id])
    render layout: false
  end

  def update
    @content_region = ContentRegion.find(params[:id])
    @content_region.update_attributes(content_region_params)
    render text: 'ok'
  end

  def move
    @content_region = ContentRegion.find(params[:id])
    case params[:content_region][:direction]
    when "right" then
      # Move region right
      # Get right adjecent content region, and swap sequence
      #throw @content_region.page.content_regions
      right_adjacent = @content_region.page.content_regions.where(row_sequence: @content_region.row_sequence, sequence: @content_region.sequence + 1).first
      if right_adjacent
        right_adjacent.update_attributes(sequence: @content_region.sequence)
        @content_region.update_attributes(sequence: @content_region.sequence + 1)
      end
      @content_region.page.resequence_content_regions! # Just to make sure a proper sequence is set, shouldn't be needed, but works kinks out
    when "left" then
      # Move region left
      # Get left adjecent content region, and swap sequence
      if @content_region.sequence > 1
        left_adjacent = @content_region.page.content_regions.where(row_sequence: @content_region.row_sequence, sequence: @content_region.sequence - 1).first
        if left_adjacent
          left_adjacent.update_attributes(sequence: @content_region.sequence)
          @content_region.update_attributes(sequence: @content_region.sequence - 1)
        end
      end
      @content_region.page.resequence_content_regions! # Just to make sure a proper sequence is set, shouldn't be needed, but works kinks out
    when "up" then
      # Move region up
    when "down" then
      # Move region down
    end
    render text: "ok"
  end

  def destroy
    @content_region = ContentRegion.find(params[:id]).destroy
    # TODO: Should delete content items that are ophaned
    render text: 'ok'
  end

  def preview
    # Previews a copy of the section
    @content_region = ContentRegion.find(params[:id])
    render text: ContentRegionRenderer.new(@content_region).render
  end


private

  def content_region_params
    #params.require(:content_region).permit(:name, :section_id, :source, :layout_id)
    params.fetch(:content_region, {}).permit(:page_id, :column_width, :pixel_height, :row_sequence)
  end

end
