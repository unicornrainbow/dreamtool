class Admin::UsersController < AdminController

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to [:admin, @user], notice: "user updated successfully."
    else
      render "edit"
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to [:admin, @user], notice: "Edition created successfully."
    else
      render "new"
    end
  end


private

  def user_params
    params.require(:user).permit(:email, :password, :organization_id)
  end

end
