class Marketplace::AgentsController < AuthenticatedController
  def new
    @agent = pharmacy.agents.build.tap do |agent|
      agent.user = User.new.tap do |user|
        user.profile = Profile.new(role: Profile::Roles::PHARMACY)
      end
    end
    authorize @agent, :new?
  end

  def create
    @agent = pharmacy.agents.build(agent_params)
    authorize @agent, :create?
    if @agent.save
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t("general.flash.create_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'new'
    end
  end

  def edit
    @agent = pharmacy.agents.find(params.fetch(:id).to_i)
    authorize @agent, :edit?
  end

  def update
    @agent = pharmacy.agents.find(params.fetch(:id).to_i)
    authorize @agent, :update?
    if @agent.update_attributes(agent_params)
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'edit'
    end
  end

  private

  def pharmacy
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end

  def agent_params
    new_params = params.dup.tap do |new_params|
      new_params[:marketplace_agent][:user_attributes].delete(:password) if new_params[:marketplace_agent][:user_attributes][:password].blank?
      new_params[:marketplace_agent][:user_attributes].delete(:password_confirmation) if new_params[:marketplace_agent][:user_attributes][:password_confirmation].blank?
    end

    new_params
    .require(:marketplace_agent)
    .permit(:superintendent, user_attributes: [
      :id,
      :email,
      :password,
      :password_confirmation,
      {
        profile_attributes: [
          :id,
          :first_name,
          :surname,
          :telephone,
          :role,
          :avatar
        ]
      }
    ])
  end
end
