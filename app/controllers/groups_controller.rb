class GroupsController < ApplicationController
  respond_to :html, :json

  def create
    @edition = Edition.find(params[:edition_id])
    @group = @edition.groups.create(group_params)
    render json: @group
  end

  def destroy
    @edition = Edition.find(params[:edition_id])
    @group = @edition.groups.find(params[:id])

    # Clear content items from group
    @group.content_items.each do |content_item|
      content_item.group_id = nil
    end
    @group.destroy
    @edition.save

    head :no_content
  end

private

  def group_params
    params.fetch(:group, {}).permit(Group.attribute_names)
  end
end
