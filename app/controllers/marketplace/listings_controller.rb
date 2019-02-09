class Marketplace::ListingsController < AuthenticatedController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 20).to_i, 50].min
    @query       = params.fetch(:query, "")
    @order       = params.fetch(:order, nil)

    @listings = Marketplace::ListingSearcher.new(
      query: @query,
      page: @page,
      per_page: @per_page,
      order: @order
    ).search
    @total_count = @listings.total_count

    # Build new line item that will be initialized with different values for each Buy button
    current_order.line_items.build if current_user.pharmacy?
  end

  def new
    @listing = pharmacy.listings.build
    @products = policy_scope(Marketplace::Product)
    authorize @listing, :new?
  end

  def show
    @listing = Marketplace::Listing.find(params.fetch(:id))
    authorize @listing, :show?
  end

  def create
    @listing = pharmacy.listings.build(listing_params).tap do |listing|
      listing.product = get_product
    end
    authorize @listing, :create?
    if @listing.valid? && @listing.save!
      redirect_to pharmacy_listings_path, flash: { success: I18n.t('marketplace.listing.flash.create_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.listing.flash.error')
      @products = policy_scope(Marketplace::Product)
      render :new
    end
  end

  def edit
    @listing = pharmacy.listings.find(params.fetch(:id))
    @products = policy_scope(Marketplace::Product)
    authorize @listing, :edit?
  end

  def update
    @listing = pharmacy.listings.find(params.fetch(:id).to_i)
    authorize @listing, :update?
    if @listing.update_attributes(listing_params)
      redirect_to pharmacy_listings_path, flash: { success: I18n.t('marketplace.listing.flash.update_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.listing.flash.error')
      @products = policy_scope(Marketplace::Product)
      render :edit
    end
  end

  def destroy
    @listing = get_scope.find(params.fetch(:id).to_i)
    authorize @listing, :destroy?
    if @listing.destroy
      redirect_to destroy_success_redirect_path, flash: { success: I18n.t('marketplace.listing.flash.destroy_successful') }
    else
      flash.now[:error] = I18n.t('general.error')
      render :show, status: :unprocessable_entity
    end
  end

  private

  def get_scope
    policy_scope(::Marketplace::Listing)
  end

  def pharmacy
    return unless pharmacy_id
    @_pharmacy ||= ::Marketplace::Pharmacy.find(pharmacy_id.to_i)
  end

  def pharmacy_listings_path
    marketplace_pharmacy_profile_path(pharmacy_id: pharmacy.id, section: 'listings')
  end

  def pharmacy_id
    params.fetch(:pharmacy_id){ nil }
  end

  def get_product
    policy_scope(Marketplace::Product).find(listing_params.fetch(:marketplace_product_id))
  end

  def listing_params
    params
    .require(:marketplace_listing)
    .permit(:marketplace_product_id, :quantity, :expiry, :price_cents, :batch_number, :seller_note, :active)
  end

  def destroy_success_redirect_path
    current_user.admin? ? marketplace_root_path : marketplace_pharmacy_listings_path(current_user.pharmacy)
  end
end
