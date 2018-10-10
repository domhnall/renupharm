class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by_id(params.fetch(:id))
    @profile = @user.profile
  end

  def edit
    @user = User.find_by_id(params.fetch(:id))
  end

  def new
    @user = User.new.tap do |u|
      u.build_profile
    end
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
    new_params = params.dup.tap do |new_params|
      new_params[:user].delete(:password) if new_params[:user][:password].blank?
      new_params[:user].delete(:password_confirmation) if new_params[:user][:password_confirmation].blank?
    end
    new_params.require(:user).permit(:email, :password, :password_confirmation, profile_attributes: [:first_name, :surname, :telephone, :role])
  end
end
