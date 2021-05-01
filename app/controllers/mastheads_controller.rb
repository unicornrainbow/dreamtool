class MastheadsController < ApplicationController

  def index
    @mastheads = Masthead.asc(:path)
  end

  def new
    @masthead = Masthead.new
  end

  def create
    @masthead = Masthead.new(masthead_params)
    if @masthead.save
      redirect_to @masthead, notice: "Masthead created successfully."
    else
      render "new"
    end
  end

  def edit
    @masthead = Masthead.find(params[:id])
    #if params
    #@edition = Edition.find(params[:id])
    #@masthead = @edition.masthead
  end

  def update
    @masthead = Masthead.find(params[:id])
    if @masthead.update_attributes(masthead_params)
      redirect_to @masthead, notice: "masthead updated successfully."
    else
      render "edit"
    end
  end

  def show
    @masthead = Masthead.find(params[:id])
    #@edition = Edition.find(params[:edition_id])
    #masthead = @edition.masthead
  end

  def destroy
    @masthead = Masthead.find(params[:id]).destroy
    redirect_to :back
  end

  def preview
    @masthead = Masthead.find(params[:id])
    renderer = MastheadRenderer.new(@masthead)
    @masthead.html = renderer.render
    @masthead.save
    render text: @masthead.html
  end

private

  def masthead_params
    params.require(:masthead).permit(:name, :source, :title)
  end

end
