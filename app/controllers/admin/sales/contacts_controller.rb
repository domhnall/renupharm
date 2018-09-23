class Admin::Sales::ContactsController < Admin::BaseController
  def index
    @sales_contacts = ::Sales::Contact.all
  end

  def new
    @sales_contact = ::Sales::Contact.new
  end

  def show
    @sales_contact = ::Sales::Contact.find(params.fetch(:id).to_i)
  end

  def create
    @sales_contact = ::Sales::Contact.new(contact_params)
    if @sales_contact.save
      redirect_to admin_sales_contact_path(@sales_contact), flash: { success: I18n.t("general.flash.create_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'new'
    end
  end

  def edit
    @sales_contact = ::Sales::Contact.find(params.fetch(:id).to_i)
  end

  def update
    @sales_contact = ::Sales::Contact.find(params.fetch(:id).to_i)
    if @sales_contact.update_attributes(contact_params)
      redirect_to admin_sales_contact_path(@sales_contact), flash: { success: I18n.t("general.flash.update_successful") }
    else
      flash[:error] = I18n.t("general.flash.error")
      render 'edit'
    end
  end

  def destroy
    @sales_contact = ::Sales::Contact.find(params.fetch(:id).to_i)
    @sales_contact.destroy
    redirect_to admin_sales_contacts_path, flash: { success: I18n.t("general.flash.delete_successful") }
  end

  private

  def contact_params
    params.require(:sales_contact).permit(:sales_pharmacy_id, :first_name, :surname, :email, :telephone)
  end
end
