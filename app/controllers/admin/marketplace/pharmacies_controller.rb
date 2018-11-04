class Admin::Marketplace::PharmaciesController < Admin::BaseController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @query       = params.fetch(:query, "")
    @total_count = get_scope(@query).count
    @total_pages = (@total_count/@per_page).ceil
    @pharmacies  = get_scope(@query).order(:name).limit(@per_page).offset((@page-1)*@per_page)
  end

  def new
    @marketplace_pharmacy = ::Marketplace::Pharmacy.new
  end

  def show
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    render "marketplace/shared/pharmacies/show"
  end

  def create
    @marketplace_pharmacy = ::Marketplace::Pharmacy.new(pharmacy_params)
    if @marketplace_pharmacy.save
      redirect_to admin_marketplace_pharmacy_path(@marketplace_pharmacy), flash: { success: I18n.t("general.flash.create_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'new'
    end
  end

  def edit
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    render "marketplace/shared/pharmacies/edit"
  end

  def update
    @marketplace_pharmacy = ::Marketplace::Pharmacy.find(params.fetch(:id).to_i)
    if @marketplace_pharmacy.update_attributes(pharmacy_params)
      redirect_to admin_marketplace_pharmacy_path(@marketplace_pharmacy), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render "marketplace/shared/pharmacies/edit"
    end
  end

  private

  def get_scope(query)
    return ::Marketplace::Pharmacy.all if query.size<3
    ::Marketplace::Pharmacy.where("name LIKE ?", "%#{query}%")
  end

  def pharmacy_params
    params
    .require(:marketplace_pharmacy)
    .permit(
      :name,
      :description,
      :address_1,
      :address_2,
      :address_3,
      :email,
      :telephone,
      :fax,
      :active,
      :image
    )
  end
end
