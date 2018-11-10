class Marketplace::OrdersController < AuthenticatedController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @total_count = get_scope(@query).count
    @total_pages = (@total_count/@per_page).ceil

    @orders = get_scope(@query)
    .not_in_progress
    .order(updated_at: :desc)
    .limit(@per_page)
    .offset((@page-1)*@per_page)
  end

  def show
    @order = current_user.pharmacy.orders.not_in_progress.find(params.fetch(:id).to_i)
  end

  private

  def get_scope(query)
    return scope = policy_scope(Marketplace::Order) if query.size<3
    scope#.where("name LIKE ?", "%#{query}%")
  end
end
