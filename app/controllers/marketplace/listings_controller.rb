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
    authorize @listing, :new
  end

  def create
  end

  def edit
  end

  def update
  end

  private

  def get_scope(query)
    return ::Marketplace::Listing.joins(:product) if query.size<3
    ::Marketplace::Listing.joins(:product).where("marketplace_products.name LIKE ?", "%#{query}%")
  end

  def pharmacy
    return unless pharmacy_id
    @_pharmacy ||= ::Marketplace::Pharmacy.find(pharmacy_id.to_i)
  end

  def pharmacy_id
    params.fetch(:pharmacy_id){ nil }
  end
end
