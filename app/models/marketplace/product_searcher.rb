class Marketplace::ProductSearcher
  attr_reader :query, :pharmacy_id, :page, :per_page, :order

  def initialize(options = {})
    @query = options.fetch(:query, "")
    @page = options.fetch(:page, 1)
    @per_page = options.fetch(:per_page, 10)
    @pharmacy_id = options.fetch(:pharmacy_id, nil)
    @order = {
      custom_first: [:marketplace_pharmacy_id, :desc],
      most_recent: [:updated_at, :desc],
    }[options[:order] || :custom_first]

  end

  def search
    @_results ||= Marketplace::Product.search do
      fulltext get_query
      paginate page: page, per_page: per_page
      order_by *order
      any_of do
        with(:marketplace_pharmacy_id, nil)
        with(:marketplace_pharmacy_id, pharmacy_id)
      end
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
