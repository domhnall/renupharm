class Marketplace::PharmaciesController < AuthenticatedController
  def show
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    authorize @marketplace_pharmacy
    render 'marketplace/shared/pharmacies/show'
  end
end
