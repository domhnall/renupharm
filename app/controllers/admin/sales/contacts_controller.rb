class Admin::Sales::ContactsController < Admin::BaseController
  def index
    @sales_contacts = ::Sales::Contact.all
  end
end
