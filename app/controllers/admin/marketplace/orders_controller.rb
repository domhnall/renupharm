class Admin::Marketplace::OrdersController < Admin::BaseController
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

  def edit
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :edit?
  end

  def update
    @order = get_scope.find(params.fetch(:id).to_i)
    authorize @order, :update?

    if @order.update_attributes(marketplace_order_params)
      redirect_to admin_marketplace_order_path(@order), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render :edit
    end
  end

  private

  def get_scope(query="")
    policy_scope(::Marketplace::Order)
  end

  def marketplace_order_params
    params.require(:marketplace_order).permit(:state)
  end
end
