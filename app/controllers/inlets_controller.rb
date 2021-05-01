class InletsController < ApplicationController

  before_action :authenticate_user!

  def index
    @inlets = Inlet.asc(:path)
  end

  def new
    @inlet = Inlet.new
  end

  def create
    @inlet = Inlet.new(inlet_params)

    if @inlet.save
      redirect_to @inlet, notice: "Inlet created successfully."
    else
      render "new"
    end
  end

  def edit
    @inlet = Inlet.find(params[:id])
  end

  def update
    @inlet = Inlet.find(params[:id])
    if @inlet.update_attributes(inlet_params)
      redirect_to @inlet, notice: "Inlet updated successfully."
    else
      render "edit"
    end
  end

  def show
    @inlet = Inlet.find(params[:id])
  end

  def destroy
    @inlet = Inlet.find(params[:id]).destroy
    redirect_to :back
  end

private

  def inlet_params
    params.require(:inlet).permit(:name, :source, :title, :masthead_id, :layout_id)
  end

end
