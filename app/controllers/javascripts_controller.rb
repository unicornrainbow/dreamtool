class JavascriptsController < ApplicationController

  before_action :authenticate_user!

  def index
    @javascripts = current_user.organization.javascripts.asc(:path)
  end

  def new
    @javascript = Javascript.new
  end

  def create
    @javascript = Javascript.new(javascript_params)

    # All edtions must have an orgnaization
    @javascript.organization = current_user.organization

    if @javascript.save
      redirect_to @javascript, notice: "javascript created successfully."
    else
      render "new"
    end
  end

  def edit
    @javascript = Javascript.find(params[:id])
  end

  def update
    @javascript = Javascript.find(params[:id])
    if @javascript.update_attributes(javascript_params)
      redirect_to @javascript, notice: "javascript updated successfully."
    else
      render "edit"
    end
  end

  def show
    @javascript = Javascript.find(params[:id])
  end

  def destroy
    @javascript = Javascript.find(params[:id]).destroy
    redirect_to :back
  end

  def preview
    # Previews a copy of the javascript
    @javascript = Javascript.find(params[:id])
    renderer = JavascriptRenderer.new(@javascript)
    @javascript.html = renderer.render
    @javascript.save
    render text: @javascript.html
  end

private

  def javascript_params
    params.require(:javascript).permit(:name, :source, :title, :masthead_id, :layout_id)
  end

end
