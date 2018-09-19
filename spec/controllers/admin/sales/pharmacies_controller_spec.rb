require 'rails_helper'

describe Admin::Sales::PharmaciesController do
  include Factories

  it_behaves_like "a basic admin controller"

  describe "an authenticated admin" do
    before :all do
      @admin = create_user(email: 'dom@renupharm.ie')
      @pharmacy = Sales::Pharmacy.create!({
        name: "Bloggs",
        address_1: "8a Greenan Road",
        address_3: "Caketown",
        email: "joe@bloggs.com"
      })
    end

    before :each do
      sign_in @admin
    end

    describe "#index" do
      render_views

      it "should display name for each Sales::Pharmacy" do
        get :index
        expect(response.body).to include @pharmacy.name
      end
    end
  end
end
