class Marketplace::PharmaciesController < AuthenticatedController
  def show
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    authorize @marketplace_pharmacy
    render 'marketplace/shared/pharmacies/show'
  end

  def edit
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    authorize @marketplace_pharmacy
    @marketplace_pharmacy = ::Marketplace::Pharmacy.active.where(id: current_user.pharmacy.id).find(params.fetch(:id).to_i)
    render 'marketplace/shared/pharmacies/edit'
  end

  def update
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    authorize @marketplace_pharmacy
    if @marketplace_pharmacy.update_attributes(pharmacy_params)
      redirect_to marketplace_pharmacy_path(@marketplace_pharmacy), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'marketplace/shared/pharmacies/edit'
    end
  end

  private

  def pharmacy_params
    params.require(:marketplace_pharmacy).permit(:name, :description, :address_1, :address_2, :address_3, :email, :telephone, :fax)
  end
end
