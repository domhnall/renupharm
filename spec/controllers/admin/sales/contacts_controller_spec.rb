require 'rails_helper'

describe Admin::Sales::ContactsController do
  include Factories

  it_behaves_like "a basic admin controller"

  describe "an authenticated admin" do
    before :all do
      @admin = create_user(email: 'dom@renupharm.ie')
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
