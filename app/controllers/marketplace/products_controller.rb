class Marketplace::ProductsController < AuthenticatedController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @order       = params.fetch(:order, :custom_first)

    @products = Marketplace::ProductSearcher.new(
      query: @query,
      page: @page,
      per_page: @per_page,
      order: @order,
      pharmacy_id: pharmacy&.id
    ).search
    @total_count = @products.total_count
    @total_pages = (@total_count/@per_page).ceil

    respond_to do |format|
      format.html { render :index }
      format.json do
        render json: {
          products: @products.as_json(methods: [:image_urls, :display_pack_size, :display_strength, :product_form_name]),
          total_count: @total_count,
          query: @query
        }
      end
    end
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

  def destroy
    @product = get_scope.find(params.fetch(:id).to_i)
    authorize @product, :destroy?
    if @product.destroy
      redirect_to destroy_success_redirect_path, flash: { success: I18n.t('marketplace.product.flash.destroy_successful') }
    else
      flash.now[:error] = I18n.t('general.error')
      render :show, status: :unprocessable_entity
    end
  end

  private

  def get_scope
    policy_scope(::Marketplace::Product)
  end

  def pharmacy
    return unless current_user.pharmacy? && params.fetch(:pharmacy_id, nil).to_i==current_user.pharmacy.id
    current_user.pharmacy
  end

  def product_params
    params
    .require(:marketplace_product)
    .permit(:name, :active_ingredient, :form, :strength, :pack_size, :manufacturer, :active, :delete_images, images: [])
  end

  def destroy_success_redirect_path
    current_user.admin? ? marketplace_products_path : marketplace_pharmacy_products_path(current_user.pharmacy)
  end
end
