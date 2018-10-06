class Admin::Sales::PharmaciesController < Admin::BaseController
  def index
    @page        = params.fetch(:page, 1).to_i
    @per_page    = [params.fetch(:per_page, 25).to_i, 50].min
    @total_count = ::Sales::Pharmacy.count
    @total_pages = (@total_count/@per_page).ceil
    @pharmacies  = ::Sales::Pharmacy.order(:name).limit(@per_page).offset((@page-1)*@per_page)
  end

  def new
    @sales_pharmacy = ::Sales::Pharmacy.new
  end

  def show
    @sales_pharmacy = ::Sales::Pharmacy.find(params.fetch(:id).to_i)
  end

  def create
    @sales_pharmacy = ::Sales::Pharmacy.new(pharmacy_params)
    if @sales_pharmacy.save
      redirect_to admin_sales_pharmacy_path(@sales_pharmacy), flash: { success: I18n.t("general.flash.create_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'new'
    end
  end

  def edit
    @sales_pharmacy = ::Sales::Pharmacy.find(params.fetch(:id).to_i)
  end

  def update
    @sales_pharmacy = ::Sales::Pharmacy.find(params.fetch(:id).to_i)
    if @sales_pharmacy.update_attributes(pharmacy_params)
      redirect_to admin_sales_pharmacy_path(@sales_pharmacy), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'edit'
    end
  end

  def destroy
    @sales_pharmacy = ::Sales::Pharmacy.find(params.fetch(:id).to_i)
    @sales_pharmacy.destroy
    redirect_to admin_sales_pharmacies_path, flash: { success: I18n.t("general.flash.delete_successful") }
  end

  private

  def pharmacy_params
    params.require(:sales_pharmacy).permit(:name, :proprietor, :address_1, :address_2, :address_3, :email, :telephone, :fax)
  end
end
