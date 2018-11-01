class Marketplace::ListingsController < AuthenticatedController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @total_count = get_scope(@query).count
    @total_pages = (@total_count/@per_page).ceil
    @listings    = get_scope(@query).order("marketplace_products.name").limit(@per_page).offset((@page-1)*@per_page)
  end

  def new
    @listing = pharmacy.listings.build
    @products = policy_scope(Marketplace::Product)
    authorize @listing, :new?
  end

  def create
    @listing = pharmacy.listings.build(listing_params).tap do |listing|
      listing.product = get_product
    end
    authorize @listing, :create?
    if @listing.valid? && @listing.save!
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t('marketplace.listing.flash.create_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.listing.flash.error')
      @products = policy_scope(Marketplace::Product)
      render :new
    end
  end

  def edit
  end

  def update
    byebug
  end

  private

  def get_scope(query)
    return ::Marketplace::Listing.joins(:product).active_listings if query.size<3
    ::Marketplace::Listing.joins(:product).active_listings.where("marketplace_products.name LIKE ?", "%#{query}%")
  end

  def pharmacy
    return unless pharmacy_id
    @_pharmacy ||= ::Marketplace::Pharmacy.find(pharmacy_id.to_i)
  end

  def pharmacy_id
    params.fetch(:pharmacy_id){ nil }
  end

  def get_product
    policy_scope(Marketplace::Product).find(listing_params.fetch(:marketplace_product_id))
  end

  def listing_params
    params.require(:marketplace_listing).permit(:marketplace_product_id, :quantity, :expiry, :price_cents, :active)
  end
end
