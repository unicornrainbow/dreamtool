class StylesheetsController < ApplicationController

  before_action :authenticate_user!

  def index
    @stylesheets = current_user.organization.stylesheets.asc(:path)
  end

  def new
    @stylesheet = Stylesheet.new
  end

  def create
    @stylesheet = Stylesheet.new(stylesheet_params)

    # All edtions must have an orgnaization
    @stylesheet.organization = current_user.organization

    if @stylesheet.save
      redirect_to @stylesheet, notice: "Stylesheet created successfully."
    else
      render "new"
    end
  end

  def edit
    @stylesheet = Stylesheet.find(params[:id])
  end

  def update
    @stylesheet = Stylesheet.find(params[:id])
    if @stylesheet.update_attributes(stylesheet_params)
      redirect_to @stylesheet, notice: "Stylesheet updated successfully."
    else
      render "edit"
    end
  end

  def show
    @stylesheet = Stylesheet.find(params[:id])
  end

  def destroy
    @stylesheet = Stylesheet.find(params[:id]).destroy
    redirect_to :back
  end

  def preview
    # Previews a copy of the stylesheet
    @stylesheet = Stylesheet.find(params[:id])
    renderer = StylesheetRenderer.new(@stylesheet)
    @stylesheet.html = renderer.render
    @stylesheet.save
    render text: @stylesheet.html
  end

private

  def stylesheet_params
    params.require(:stylesheet).permit(:name, :source, :title, :masthead_id, :layout_id)
  end

end
