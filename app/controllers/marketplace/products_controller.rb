class Marketplace::ProductsController < AuthenticatedController
  def new
    @product = pharmacy.products.build
    authorize @product, :new
  end

  def create
  end

  def edit
  end

  def update
  end

  private

  def pharmacy
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end
end
