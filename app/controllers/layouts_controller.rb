class LayoutsController < ApplicationController

  def index
    @layouts = Layout.asc(:path)
  end

  def new
    @layout = Layout.new
  end

  def create
    @layout = Layout.new(layout_params)
    if @layout.save
      redirect_to @layout, notice: "Layout created successfully."
    else
      render "new"
    end
  end

  def edit
    @layout = Layout.find(params[:id])
    #if params
    #@edition = Edition.find(params[:id])
    #@layout = @edition.layout
  end

  def update
    @layout = Layout.find(params[:id])
    if @layout.update_attributes(layout_params)
      redirect_to @layout, notice: "layout updated successfully."
    else
      render "edit"
    end
  end

  def show
    @layout = Layout.find(params[:id])
    #@edition = Edition.find(params[:edition_id])
    #layout = @edition.layout
  end

  def destroy
    @layout = Layout.find(params[:id]).destroy
    redirect_to :back
  end

private

  def layout_params
    params.require(:layout).permit(:name, :source, :parent_layout_id)
  end

end
