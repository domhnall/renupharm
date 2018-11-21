class Marketplace::SalesController < AuthenticatedController
  before_action :verify_pharmacy!

  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @total_count = get_scope(@query).count
    @total_pages = (@total_count/@per_page).ceil

    @orders = get_scope(@query).limit(@per_page).offset((@page-1)*@per_page)

    render 'marketplace/orders/index'
  end

  def show
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :show?
    render 'marketplace/orders/show'
  end

  private

  def verify_pharmacy!
    raise Errors::AccessDenied if (current_user.pharmacy? && current_user.pharmacy!=get_pharmacy)
  end

  def get_pharmacy
    @_pharmacy ||= Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end

  def get_scope(query)
    return scope = policy_scope(Marketplace::Sale) if query.size<3
    scope#.where("name LIKE ?", "%#{query}%")
  end
end
