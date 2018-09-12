class Sales::ContactsController < ApplicationController
  def create
    if @sales_contact = Sales::Contact.find_by_email(sales_contact_params[:email])
      @sales_contact.update_attributes(sales_contact_params)
      redirect_to(root_path, flash: {info: I18n.t("pages.index.register_interest.already_exists")}) && return
    end

    @sales_contact = Sales::Contact.new(sales_contact_params)
    if @sales_contact.valid?
      @sales_contact.save!
      redirect_to root_path, flash: { success: I18n.t("pages.index.register_interest.success") }
    else
      redirect_to root_path, flash: { warning: I18n.t("pages.index.register_interest.error") }
    end
  end

  private

  def sales_contact_params
    params.require(:sales_contact).permit(:first_name, :surname, :email)
  end
end
