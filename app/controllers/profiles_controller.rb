class ProfilesController < AuthenticatedController
  skip_before_action :redirect_to_accept_terms, only: [:accept_terms_and_conditions, :update]

  def show
    @profile = current_user.profile
  end

  def edit
    @profile = current_user.profile
  end

  def accept_terms_and_conditions
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update_attributes(profile_params)
      redirect_to profile_path, flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render(@profile.accepted_terms ? 'edit' : 'accept_terms_and_conditions')
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :surname, :telephone, :avatar, :accepted_terms)
  end
end
