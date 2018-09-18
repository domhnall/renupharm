class Admin::Sales::Contacts < Admin::BaseController
  def index
    @sales_contacts = Sales::Contact.all
  end
end
