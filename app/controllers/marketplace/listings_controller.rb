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
    @listing = pharmacy.listings.find(params.fetch(:id))
    @products = policy_scope(Marketplace::Product)
    authorize @listing, :edit?
  end

  def update
    @listing = pharmacy.listings.find(params.fetch(:id).to_i)
    authorize @listing, :update?
    if @listing.update_attributes(listing_params)
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t('marketplace.listing.flash.update_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.listing.flash.error')
      @products = policy_scope(Marketplace::Product)
      render :edit
    end
  end

  private

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
    params
    .require(:marketplace_listing)
    .permit(:marketplace_product_id, :quantity, :expiry, :price_cents, :batch_number, :seller_note, :active)
  end
end
