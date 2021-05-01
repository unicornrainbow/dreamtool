class Admin::OrganizationsController < AdminController

  def index
    @organizations = Organization.all
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      redirect_to [:admin, @organization], notice: "Edition created successfully."
    else
      render "new"
    end
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(organization_params)
      redirect_to [:admin, @organization], notice: "organization updated successfully."
    else
      render "edit"
    end
  end

private

  def organization_params
    params.require(:organization).permit(:name)
  end

end
