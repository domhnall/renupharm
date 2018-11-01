class Marketplace::ProductsController < AuthenticatedController
  def new
    @product = pharmacy.products.build
    authorize @product, :new?
  end

  def create
    @product = pharmacy.products.build(product_params)
    authorize @product, :create?
    if @product.valid? && @product.save
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t('marketplace.product.flash.create_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.product.flash.error')
      render :new
    end
  end

  def edit
    @product = pharmacy.products.find(params.fetch(:id).to_i)
    authorize @product, :edit?
  end

  def update
    @product = pharmacy.products.find(params.fetch(:id).to_i)
    authorize @product, :update?
    if @product.update_attributes(product_params)
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t('marketplace.product.flash.update_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.product.flash.error')
      render :new
    end
  end

  private

  def pharmacy
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end

  def product_params
    params.require(:marketplace_product).permit(:name, :description, :unit_size, :active, images: [])
  end
end
