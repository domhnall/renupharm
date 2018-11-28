class Marketplace::ProductsController < AuthenticatedController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @total_count = get_scope(@query).count
    @total_pages = (@total_count/@per_page).ceil

    @products = get_scope(@query).limit(@per_page).offset((@page-1)*@per_page)
  end

  def show
    @product = get_scope.find(params.fetch(:id).to_i)
    authorize @product, :show?
  end

  def new
    @product = Marketplace::Product.new(pharmacy: pharmacy)
    @url = pharmacy ? marketplace_pharmacy_products_path(pharmacy) : marketplace_products_path
    authorize @product, :new?
  end

  def create
    @product = Marketplace::Product.new(product_params.merge(marketplace_pharmacy_id: pharmacy&.id))
    authorize @product, :create?
    if @product.valid? && @product.save
      redirect_to marketplace_product_path(@product), flash: { success: I18n.t('marketplace.product.flash.create_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.product.flash.error')
      render :new
    end
  end

  def edit
    @product = get_scope.find(params.fetch(:id).to_i)
    @url = pharmacy ? marketplace_pharmacy_product_path(pharmacy, @product) : marketplace_product_path(@product)
    authorize @product, :edit?
  end

  def update
    @product = get_scope.find(params.fetch(:id).to_i)
    @product.assign_attributes(product_params.merge(marketplace_pharmacy_id: pharmacy&.id))
    authorize @product, :update?
    if @product.valid? && @product.save!
      redirect_to marketplace_product_path(@product), flash: { success: I18n.t('marketplace.product.flash.update_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.product.flash.error')
      render :edit
    end
  end

  private

  def get_scope(query="")
    return scope = policy_scope(::Marketplace::Product) if query.size<3
    scope.where("name LIKE ?", "%#{query}%")
  end

  def pharmacy
    return unless current_user.pharmacy? && params.fetch(:pharmacy_id, nil).to_i==current_user.pharmacy.id
    current_user.pharmacy
  end

  def product_params
    params.require(:marketplace_product).permit(:name, :description, :unit_size, :active, :delete_images, images: [])
  end
end
