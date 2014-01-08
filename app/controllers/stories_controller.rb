class StoriesController < ApplicationController
  def index
    @stories = Story.desc(:name)
  end

  def new
    @story = Story.new
  end

  def create
    @story = Story.new(story_params)
    if @story.save
      redirect_to @story, notice: "Story created successfully."
    else
      render "new"
    end
  end

  def show
    @story = Story.find(params[:id])
  end

  def delete
    @story = Story.find(params[:id]).destroy
    redirect_to :back
  end

private

  def story_params
    params.require(:story).permit(:name, :body)
  end

end
