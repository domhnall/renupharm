require 'rails_helper'

describe Admin::Sales::ContactsController do
  include Factories

  before :all do
    @pharmacy = Sales::Pharmacy.create!({
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4, Irishtown",
      address_3: "Dublin 4",
      telephone: "(01) 283 7188",
    })
    @existing = Sales::Contact.create!({
      sales_pharmacy_id: @pharmacy.id,
      first_name: "Don",
      surname: "Draper",
      email: "don@draper.com"
    })

    @create_params = {
      sales_contact: {
        sales_pharmacy_id: @pharmacy.id,
        first_name: "Peggy",
        surname: "Olsen",
        email: "peggy@olsen.com"
      }
    }

    @update_params = @create_params.merge(id: @existing.id)
  end

  it_behaves_like "a basic admin controller with :index"
  it_behaves_like "a basic admin controller with :show"
  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :create", Sales::Contact
  it_behaves_like "a basic admin controller with :update", Sales::Contact
  it_behaves_like "a basic admin controller with :destroy", Sales::Contact

  describe "an authenticated admin" do
    before :all do
      @admin = create_admin_user(email: 'dom@renupharm.ie')
      @contact = Sales::Contact.create!({
        first_name: "Gary",
        surname: "Digney",
        email: "gary@digney.com"
      })
    end

    before :each do
      sign_in @admin
    end

    describe "#index" do
      render_views

      it "should display full name for each Sales::Contact" do
        get :index
        expect(response.body).to include @contact.full_name
      end

      it "should display email for each Sales::Contact" do
        get :index
        expect(response.body).to include @contact.email
      end
    end
  end
end
