class PartialsController < ApplicationController

  def index
    @partials = Partial.asc(:path)
  end

  def new
    @partial = Partial.new
  end

  def create
    @partial = Partial.new(partial_params)
    if @partial.save
      redirect_to @partial, notice: "partial created successfully."
    else
      render "new"
    end
  end

  def edit
    @partial = Partial.find(params[:id])
    #if params
    #@edition = Edition.find(params[:id])
    #@partial = @edition.partial
  end

  def update
    @partial = Partial.find(params[:id])
    if @partial.update_attributes(partial_params)
      redirect_to @partial, notice: "partial updated successfully."
    else
      render "edit"
    end
  end

  def show
    @partial = Partial.find(params[:id])
    #@edition = Edition.find(params[:edition_id])
    #partial = @edition.partial
  end

  def destroy
    @partial = Partial.find(params[:id]).destroy
    redirect_to :back
  end

private

  def partial_params
    params.require(:partial).permit(:name, :source)
  end

end
