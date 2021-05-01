class StoriesController < ApplicationController
  def index
    @stories = current_user.stories.desc(:updated_at)
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

  def edit
    @story = Story.find(params[:id])
  end

  def update
    @story = Story.find(params[:id])
    if @story.update_attributes(story_params)
      redirect_to @story, notice: "Story updated successfully."
    else
      render "edit"
    end
  end

  def show
    @story = Story.find(params[:id])
  end

  def destroy
    @story = Story.find(params[:id]).destroy
    redirect_to :back
  end

private

  def story_params
    params.require(:story).permit(:name, :body, :author, :source, :title)
  end

end
