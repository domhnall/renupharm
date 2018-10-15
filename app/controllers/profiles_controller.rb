class ProfilesController < AuthenticatedController
  def show
    @profile = current_user.profile
  end

  def edit
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update_attributes(profile_params)
      redirect_to profile_path, flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'edit'
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :surname, :telephone, :avatar)
  end
end
