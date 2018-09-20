class Admin::Sales::PharmaciesController < Admin::BaseController
  def index
    @pharmacies = ::Sales::Pharmacy.all
  end

  def new
    @sales_pharmacy = ::Sales::Pharmacy.new
  end

  def show
    @sales_pharmacy = Sales::Pharmacy.find(params.fetch(:id).to_i)
  end

  def create
    @sales_pharmacy = ::Sales::Pharmacy.new(pharmacy_params)
    if @sales_pharmacy.save
      redirect_to admin_sales_pharmacy_path(@sales_pharmacy), flash: { success: I18n.t("general.flash.create_successful") }
    else
      render 'new', flash: { error: I18n.t("general.flash.error") }
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
      render 'edit', flash: { error: I18n.t("general.flash.error") }
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
