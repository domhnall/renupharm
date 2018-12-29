class Marketplace::ListingSearcher
  attr_reader :query, :pharmacy_id, :page, :per_page, :order

  def initialize(options = {})
    @query = options.fetch(:query, "")
    @page = options.fetch(:page, 1)
    @per_page = options.fetch(:per_page, 10)
    @pharmacy_id = options.fetch(:pharmacy_id, nil)
    @order = {
      most_recent: [:updated_at, :desc],
      cheapest: [:price_cents, :asc],
      longest_dated: [:expiry, :desc]
    }[options[:order] || :cheapest]

  end

  def search
    @_results ||= Marketplace::Listing.search do
      fulltext get_query
      paginate page: page, per_page: per_page
      order_by *order
    end.results
  end

  def total_count
    search.total_count
  end

  def total_pages
    search.total_pages
  end

  private

  def get_query
    return "" if query.blank?
    "*#{query}*"
  end
end
