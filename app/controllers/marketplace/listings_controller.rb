class Marketplace::ListingsController < AuthenticatedController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @total_count = get_scope(@query).count
    @total_pages = (@total_count/@per_page).ceil
    @listings    = get_scope(@query).order("marketplace_products.name").limit(@per_page).offset((@page-1)*@per_page)
  end

  private

  def get_scope(query)
    return ::Marketplace::Listing.joins(:product) if query.size<3
    ::Marketplace::Listing.joins(:product).where("marketplace_products.name LIKE ?", "%#{query}%")
  end

end
