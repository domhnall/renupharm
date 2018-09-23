class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by_id(params.fetch(:id))
  end

  def edit
    @user = User.find_by_id(params.fetch(:id))
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user), flash: { success: I18n.t("general.flash.create_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'new'
    end
  end

  def update
    @user = User.find_by_id(params.fetch(:id))
    if @user.update_attributes(user_params)
      redirect_to admin_user_path(@user), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'edit'
    end
  end

  def destroy
    @user = User.find_by_id(params.fetch(:id))
    @user.destroy
    redirect_to admin_users_path, flash: { success: I18n.t("general.flash.delete_successful") }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
